// header.js - the SAME header, menu and footer on every page.
// Each page loads it like:  <script src="header.js" data-active="home"></script>
// The Officer page is deliberately NOT in the menu. The authorised officer opens officer.html directly.
(function () {
  var here = document.currentScript.getAttribute("data-active") || "";
  var items = [
    ["home", "🏠 Home", "index.html#home"],
    ["register", "✎ Register Grievance", "index.html#register"],
    ["status", "👁 View Status", "index.html#status"],
    ["dashboard", "📊 Dashboard", "dashboard.html"]
  ];
  var nav = items.map(function (i) {
    return '<a href="' + i[2] + '" data-key="' + i[0] + '">' + i[1] + '</a>';
  }).join("");
  var badge = '<svg class="site-logo" viewBox="0 0 64 64" role="img" aria-label="MCL logo placeholder">' +
    '<circle cx="32" cy="32" r="30" fill="#1e2a78"/><circle cx="32" cy="32" r="24" fill="none" stroke="#c6c063" stroke-width="2"/>' +
    '<text x="32" y="38" text-anchor="middle" font-family="Arial" font-weight="bold" font-size="16" fill="#fff">MCL</text></svg>';
  document.write(
    '<div class="site-header"><div class="inner">' +
    '<img class="site-logo" id="site-logo" src="logo.png" alt="MCL logo">' +
    '<div><h1 class="site-title">MCL Grievance Redressal Forum</h1>' +
    '<p class="site-sub">Mahanadi Coalfields Limited</p></div></div></div>' +
    '<div class="site-nav"><div class="inner">' + nav + '</div></div>');
  // If logo.png has not been uploaded yet, show a simple placeholder badge instead.
  var img = document.getElementById("site-logo");
  img.onerror = function () { img.outerHTML = badge; };

  function mark() {
    var key = here;
    if (here === "home") {
      var h = (location.hash || "#home").slice(1);
      key = (h === "register" || h === "status") ? h : "home";
    }
    Array.prototype.forEach.call(document.querySelectorAll(".site-nav a"), function (a) {
      a.className = a.getAttribute("data-key") === key ? "active" : "";
    });
  }
  mark();
  window.addEventListener("hashchange", mark);
  document.addEventListener("DOMContentLoaded", function () {
    var f = document.createElement("div");
    f.className = "site-footer";
    f.textContent = "MCL Grievance Redressal Forum - practice tool. All data shown here is made up.";
    document.body.appendChild(f);
  });
})();
