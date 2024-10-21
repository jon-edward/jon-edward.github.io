import "./style.css";

const projectsSection = document.getElementById("projects")!;
const aboutMeSection = document.getElementById("about-me")!;

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
