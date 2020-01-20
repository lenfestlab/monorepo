import React from "react";
import ReactDOM from "react-dom";

import { AdminApp } from "../components/admin";

document.addEventListener("DOMContentLoaded", () => {
  ReactDOM.render(
    <AdminApp />,
    document.body.appendChild(document.createElement("div"))
  );
});
