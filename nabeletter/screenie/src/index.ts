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
import icalendar from "icalendar";
import { JSDOM } from "jsdom";
import parseMoney from "parse-money";
import mjml2html from "mjml";
import util from "util";
import bodyParser from "body-parser";

const app = express();
const port = process.env.PORT || 5000;

app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.use(bodyParser.raw());

app.use(cors());

let server: Server;
if (process.env.NODE_ENV === "production") {
  server = http.createServer(app);
} else {
  const key = fs.readFileSync(path.resolve(process.env.PATH_SSL_KEY!));
  const cert = fs.readFileSync(path.resolve(process.env.PATH_SSL_CERT!));
  server = https.createServer({ key, cert }, app);
}

app.post("/mjml", (req, res) => {
  try {
    const mjml = req.body.mjml;
    // console.dir(mjml, { depth: null, colors: true });
    const result = mjml2html(mjml, { minify: true, validationLevel: "strict" });
    res.status(200).json(result);
  } catch (error) {
    console.error(error);
    res.status(400).json({
      error: true,
      message: error.message,
    });
  }
});

app.get("/properties", async (req, res) => {
  const get = (
    outerEle: HTMLElement,
    sel: string,
    attr: string
  ): string | null | undefined => {
    const element = outerEle.querySelector(sel);
    if (!element) console.error("MIA: element", element);
    const attribute = element?.getAttribute(attr);
    if (!attribute) console.error("MIA: attribute", attribute);
    return attribute;
  };

  try {
    const _url = req.query.url as string;
    if (!_url) throw new Error(`MIA: url param`);
    const dom = await JSDOM.fromURL(_url, { runScripts: "dangerously" });
    const doc = dom.window.document;
    const head = doc.head;
    const body = doc.body;
    // sold-on date
    let sold_on = null;
    const matches = body.innerHTML.match(/\d{2}\/\d{2}\/\d{2}/);
    if (matches) sold_on = matches[0];
    // <meta property="og:url" content="https://www.zillow.com:443/homedetails/.."
    const url = get(head, `meta[property="og:url"]`, "content");
    // <meta property="og:image" content="https://....jpg">
    const image = get(head, `meta[property="og:image"]`, "content");
    // <meta property="og:zillow_fb:address" content="420 E Thompson St, Philadelphia, PA 19125">
    const address = get(
      head,
      `meta[property="og:zillow_fb:address"]`,
      "content"
    );
    // <meta property="zillow_fb:beds" content="3">
    const beds = get(head, `meta[property="zillow_fb:beds"]`, "content");
    // <meta property="zillow_fb:baths" content="2">
    const baths = get(head, `meta[property="zillow_fb:baths"]`, "content");
    // <meta property="zillow_fb:description" content="For sale...
    const description = get(
      head,
      `meta[property="zillow_fb:description"]`,
      "content"
    );
    // meta property="product:price:amount" content="339000.00"/>
    let price = null;
    price = get(head, `meta[property='product:price:amount']`, "content");
    if (!price && description) {
      const money = parseMoney(description);
      if (money) price = money.amount.toString();
    }
    const data = {
      url,
      price,
      image,
      address,
      beds,
      baths,
      description,
      sold_on,
    };
    console.debug("data", data);
    res.status(200).json(data);
  } catch (error) {
    res.status(400).json({
      error: true,
      message: error.message,
    });
  }
});

app.get("/ics", async (req, res) => {
  try {
    const { uid, summary, dstart, dend, description, location } = req.query;
    var event = new icalendar.VEvent(uid);
    event.setSummary(summary);
    event.setDate(new Date(dstart as string), new Date(dend as string));
    event.setDescription(description);
    event.setLocation(location);
    const body = event.toString();
    const filename = "event.ics";
    res.setHeader("Content-disposition", "attachment; filename=" + filename);
    res.setHeader("Content-type", "text/calendar");
    res.send(body);
    res.useChunkedEncodingByDefault;
  } catch (error) {
    res.status(400).json({
      error: true,
      message: error.message,
    });
  }
});

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
    const encoded = encodeURIComponent(url);
    const app_id = process.env.FB_APP_ID;
    const client_token = process.env.FB_CLIENT_TOKEN;
    const access_token = `${app_id}|${client_token}`;
    switch (domain) {
      // https://developer.twitter.com/en/docs/tweets/post-and-engage/api-reference/get-statuses-oembed
      case "twitter.com":
        embedURL = `https://publish.twitter.com/oembed?url=${url}`;
        break;
      case "instagram.com":
        embedURL = `https://graph.facebook.com/v8.0/instagram_oembed?access_token=${access_token}&url=${encoded}`;
        break;
      case "facebook.com":
        if (url.includes("video")) {
          embedURL = `https://graph.facebook.com/v8.0/oembed_video?access_token=${access_token}&url=${encoded}`;
        } else {
          embedURL = `https://graph.facebook.com/v8.0/oembed_post?access_token=${access_token}&url=${encoded}`;
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
        "//platform.instagram.com/en_US/embeds.js",
        "https://platform.instagram.com/en_US/embeds.js"
      );
    }

    // init browser
    const browser = await puppeteer.launch({
      headless: true,
      args: ["--no-sandbox", "--disable-setuid-sandbox"],
    });
    const page = await browser.newPage();
    const ua = process.env.FAKE_USER_AGENT;
    await page.setUserAgent(ua ?? (await browser.userAgent()));
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

app.post("/adcapture", async (req, res) => {
  try {
    console.info("req.body", req.body);
    const { identifier, html, selector } = req.body;
    if (!html) throw new Error(`MIA: html param`);
    console.info("html", html);
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
      waitUntil: "networkidle2",
    });
    // screenshot embed ele
    // https://gist.github.com/malyw/b4e8284e42fdaeceab9a67a9b0263743#file-index-js-L18-L46
    // https://gist.github.com/malyw/b4e8284e42fdaeceab9a67a9b0263743#gistcomment-2776083
    const ele = await page.$(selector);
    if (!ele) throw new Error(`MIA: page element with selector '${selector}'`);
    const screenshot = await ele.screenshot({
      omitBackground: true,
      encoding: "binary",
    });
    await browser.close();
    // upload image
    const api = cloudinary.v2;
    const public_id = crypto.createHash("md5").update(identifier).digest("hex");
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
    const data = { screenshot_url, image_id: public_id };
    console.info("response.data", data);
    res.status(200).json(data);
  } catch (error) {
    console.error(error);
    const json = { error: true, message: error.message };
    console.error(json);
    res.status(400).json(json);
  }
});

app.get("/", (req, res) => {
  res.send("TODO");
});

server.listen(port, () => {
  return console.log(`server is listening on ${port}`);
});
