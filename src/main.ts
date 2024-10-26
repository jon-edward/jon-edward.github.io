import "./style.css";

const projectsSection = document.getElementById("projects")!;
const aboutMeSection = document.getElementById("about-me")!;

const box2dExample = document.getElementById("box2d-example")!;

function handleHash(hash: string) {
  switch (hash) {
    case "#projects":
      window.scrollTo({
        top: projectsSection.offsetTop,
        behavior: "smooth",
      });
      break;
    case "#about-me":
      window.scrollTo({
        top: aboutMeSection.offsetTop,
        behavior: "smooth",
      });
      break;
    default:
      break;
  }
}

handleHash(window.location.hash);

window.onhashchange = (_event) => {
  handleHash(window.location.hash);
};

window.onpopstate = (_event) => {
  handleHash(window.location.href);
};

function setInnerHTML(elem: HTMLElement, html: string) {
  elem.innerHTML = html;

  Array.from(elem.querySelectorAll("script")).forEach((oldScriptEl) => {
    const newScriptEl = document.createElement("script");

    Array.from(oldScriptEl.attributes).forEach((attr) => {
      newScriptEl.setAttribute(attr.name, attr.value);
    });

    const scriptText = document.createTextNode(oldScriptEl.innerHTML);
    newScriptEl.appendChild(scriptText);

    oldScriptEl.parentNode!.replaceChild(newScriptEl, oldScriptEl);
  });
}

box2dExample.onclick = async () => {
  box2dExample.onclick = null;
  box2dExample.style.cursor = "default";

  const shellHtml = await (await fetch("box2dExample.html")).text();

  box2dExample.style.height = `${Math.floor(box2dExample.clientHeight)}px`;
  // Give container height, this prevents collapsing when inner HTML is swapped.
  // This is removed on WASM runtime initialization.

  setInnerHTML(box2dExample, shellHtml);
};
