import cloudinary, {
  UploadApiErrorResponse,
  UploadApiOptions,
  UploadApiResponse,
} from "cloudinary";
import cors from "cors";
import crypto from "crypto";
import express from "express";
import fs from "fs";
import http, { Server } from "http";
import https from "https";
import fetch from "node-fetch";
import path from "path";
import puppeteer from "puppeteer";

const app = express();
const port = process.env.PORT || 5000;

app.use(cors());

let server: Server;
if (process.env.NODE_ENV === "production") {
  server = http.createServer(app);
} else {
  const key = fs.readFileSync(path.resolve(process.env.PATH_SSL_KEY!));
  const cert = fs.readFileSync(path.resolve(process.env.PATH_SSL_CERT!));
  server = https.createServer({ key, cert }, app);
}

interface OEmbed {
  html: string;
}

app.get("/capture", async (req, res) => {
  try {
    const url = req.query.url as string;
    if (!url) throw new Error(`MIA: url param`);
    console.info("url", url);
    let embedURL;
    const domain = new URL(url).hostname.replace("www.", "");
    switch (domain) {
      // https://developer.twitter.com/en/docs/tweets/post-and-engage/api-reference/get-statuses-oembed
      case "twitter.com":
        embedURL = `https://publish.twitter.com/oembed?url=${url}`;
        break;
      case "instagram.com":
        embedURL = `https://api.instagram.com/oembed/?maxwidth=600&url=${url}`;
        break;
      case "facebook.com":
        const encoded = encodeURIComponent(url);
        console.debug("encoded", encoded);
        if (url.includes("video")) {
          embedURL = `https://www.facebook.com/plugins/video/oembed.json/?url=${encoded}`;
        } else {
          embedURL = `https://www.facebook.com/plugins/post/oembed.json/?url=${encoded}`;
        }
        break;
      default:
        throw new Error("Unsupported embed provider");
    }
    const json: OEmbed = await fetch(embedURL).then((response) =>
      response.json()
    );
    console.debug(json);
    let html: string | undefined = json?.html;
    if (!html) {
      throw new Error("MIA: embed widget html from oembed API response");
    }
    // NOTE: fix embed HTML where necessary
    if (domain == "instagram.com") {
      html = html.replace(
        "//www.instagram.com/embed.js",
        "https://instagram.com/embed.js"
      );
    }
    console.debug(html);
    // init browser
    const browser = await puppeteer.launch({
      args: ["--no-sandbox", "--disable-setuid-sandbox"],
    });
    const page = await browser.newPage();
    await page.setViewport({
      width: 800,
      height: 800,
      isLandscape: true,
      deviceScaleFactor: 2,
    });
    await page.setContent(html, {
      waitUntil: "networkidle2", // wait on embed script
    });
    // screenshot embed ele
    // https://gist.github.com/malyw/b4e8284e42fdaeceab9a67a9b0263743#file-index-js-L18-L46
    // https://gist.github.com/malyw/b4e8284e42fdaeceab9a67a9b0263743#gistcomment-2776083
    let selector;
    switch (domain) {
      case "twitter.com":
        selector = `.twitter-tweet`;
        break;
      case "instagram.com":
        selector = ".instagram-media";
        break;
      case "facebook.com":
        selector = ".fb_iframe_widget";
        break;
      default:
        throw new Error("Unsupported embed provider");
    }
    const ele = await page.$(selector);
    if (!ele) throw new Error(`MIA: page element ${selector}`);
    const screenshot = await ele.screenshot({
      omitBackground: true,
      encoding: "binary",
    });
    await browser.close();
    // upload image
    const api = cloudinary.v2;
    const public_id = crypto.createHash("md5").update(url).digest("hex");
    const apiUploadOpts: UploadApiOptions = { public_id, overwrite: true };
    const screenshot_url: string = await new Promise<string>(
      (resolve, reject) => {
        api.uploader
          .upload_stream(
            apiUploadOpts,
            (
              error: UploadApiErrorResponse | undefined,
              result: UploadApiResponse | undefined
            ) => {
              if (error) reject(new Error(error.message));
              const upload_url: string | undefined = result?.secure_url;
              if (!upload_url) throw new Error("MIA: upload_url");
              resolve(upload_url);
            }
          )
          .end(screenshot);
      }
    );
    const data = { screenshot_url, url, image_id: public_id };
    console.info("response.data", data);
    res.status(200).json(data);
  } catch (error) {
    console.error(error);
    const json = { error: true, message: error.message };
    console.error(json);
    res.status(400).json(json);
  }
});

app.get("/darksky", async (req, res) => {
  try {
    const key = process.env.DARKSKY_API_KEY;
    const lat = req.query.lat;
    const lng = req.query.lng;
    const url = `https://api.darksky.net/forecast/${key}/${lat},${lng}?exclude=currently,hourly,minutely,flags`;
    const response = await fetch(url);
    const json = await response.json();
    res.status(200).json(json);
  } catch (error) {
    res.status(400).json({
      error: true,
      message: error.message,
    });
  }
});

interface ImageData {
  id: string;
  width: number;
  height: number;
  url: string;
}

app.get("/images", async (req, res) => {
  try {
    const url = req.query.url as string;
    if (!url) throw new Error(`MIA: url param`);
    const response = await fetch(url);
    const buffer = await response.buffer();

    const api = cloudinary.v2;
    const public_id = crypto.createHash("md5").update(url).digest("hex");
    const width = req.query.width as string;
    const apiUploadOpts: UploadApiOptions = {
      public_id,
      overwrite: true,
      transformation: [{ width, crop: "limit" }],
    };
    const data: ImageData = await new Promise<ImageData>((resolve, reject) => {
      api.uploader
        .upload_stream(
          apiUploadOpts,
          (
            error: UploadApiErrorResponse | undefined,
            result: UploadApiResponse | undefined
          ) => {
            if (error) reject(new Error(error.message));
            if (result) {
              const { public_id: id, secure_url: url, width, height } = result;
              const image = { id, url, width, height };
              if (!url) throw new Error("MIA: secure_url");
              resolve(image);
            }
          }
        )
        .end(buffer);
    });
    console.info("response.data", data);
    res.set("Cache-Control", "private, max-age=31557600, immutable");
    res.status(200).json(data);
  } catch (error) {
    res.status(400).json({
      error: true,
      message: error.message,
    });
  }
});

app.get("/", (req, res) => {
  res.send("TODO");
});

server.listen(port, () => {
  return console.log(`server is listening on ${port}`);
});
