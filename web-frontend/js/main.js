// Enhanced main.js with animations and improved functionality
document.addEventListener("DOMContentLoaded", function () {
  // Mobile navigation toggle
  const hamburger = document.querySelector(".hamburger");
  const navLinks = document.querySelector(".nav-links");

  hamburger.addEventListener("click", function () {
    hamburger.classList.toggle("active");
    navLinks.classList.toggle("active");
  });

  // Close mobile menu when clicking on a nav link
  document.querySelectorAll(".nav-links a").forEach((link) => {
    link.addEventListener("click", () => {
      hamburger.classList.remove("active");
      navLinks.classList.remove("active");
    });
  });

  // Smooth scrolling for anchor links
  document.querySelectorAll('a[href^="#"]').forEach((anchor) => {
    anchor.addEventListener("click", function (e) {
      e.preventDefault();
      const targetId = this.getAttribute("href");
      if (targetId === "#") return;

      const targetElement = document.querySelector(targetId);
      if (targetElement) {
        window.scrollTo({
          top: targetElement.offsetTop - 70,
          behavior: "smooth",
        });
      }
    });
  });

  // Add active class to nav links based on scroll position
  window.addEventListener("scroll", function () {
    const sections = document.querySelectorAll("section");
    const navLinks = document.querySelectorAll(".nav-links a");

    let currentSection = "";

    sections.forEach((section) => {
      const sectionTop = section.offsetTop;
      const sectionHeight = section.clientHeight;

      if (pageYOffset >= sectionTop - 150) {
        currentSection = section.getAttribute("id");
      }
    });

    navLinks.forEach((link) => {
      link.classList.remove("active");
      if (link.getAttribute("href") === `#${currentSection}`) {
        link.classList.add("active");
      }
    });
  });

  // Animation on scroll
  const animateOnScroll = function () {
    const elements = document.querySelectorAll(".animate-on-scroll");

    elements.forEach((element) => {
      const elementPosition = element.getBoundingClientRect().top;
      const windowHeight = window.innerHeight;

      if (elementPosition < windowHeight - 50) {
        element.classList.add("animated");
      }
    });
  };

  window.addEventListener("scroll", animateOnScroll);
  animateOnScroll(); // Run once on page load

  // Code highlighting
  document.querySelectorAll("pre code").forEach((block) => {
    // Simple syntax highlighting for demonstration
    const text = block.innerHTML;

    // Highlight comments
    let highlighted = text.replace(
      /(#.+)$/gm,
      '<span class="comment">$1</span>',
    );

    // Highlight keywords
    const keywords = [
      "import",
      "from",
      "def",
      "class",
      "return",
      "if",
      "else",
      "for",
      "while",
      "in",
      "with",
      "as",
      "try",
      "except",
      "git",
      "pip",
      "python",
    ];
    keywords.forEach((keyword) => {
      const regex = new RegExp(`\\b${keyword}\\b`, "g");
      highlighted = highlighted.replace(
        regex,
        `<span class="keyword">${keyword}</span>`,
      );
    });

    // Highlight strings
    highlighted = highlighted.replace(
      /(['"])(?:(?=(\\?))\2.)*?\1/g,
      '<span class="string">$&</span>',
    );

    block.innerHTML = highlighted;
  });

  // Add parallax effect to hero section
  window.addEventListener("scroll", function () {
    const scrollPosition = window.pageYOffset;
    const heroSection = document.querySelector(".hero");

    if (heroSection) {
      const heroBackground = heroSection.querySelector(".hero-image");
      if (heroBackground) {
        heroBackground.style.transform = `translateY(${scrollPosition * 0.2}px)`;
      }
    }
  });

  // Add counter animation to metrics
  const animateCounter = (element, target, duration = 2000) => {
    let start = 0;
    const increment = target / (duration / 16);
    const timer = setInterval(() => {
      start += increment;
      element.textContent = Math.floor(start);
      if (start >= target) {
        element.textContent = target;
        clearInterval(timer);
      }
    }, 16);
  };

  // Animate metrics when they come into view
  const metricsObserver = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          const numericCells = entry.target.querySelectorAll(
            "td:not(:first-child)",
          );
          numericCells.forEach((cell) => {
            const value = parseFloat(cell.textContent);
            if (!isNaN(value) && !cell.classList.contains("animated")) {
              cell.classList.add("animated");
              if (cell.textContent.includes("%")) {
                cell.textContent = "0%";
                const timer = setInterval(() => {
                  const current = parseInt(cell.textContent);
                  if (current < value) {
                    cell.textContent = current + 1 + "%";
                  } else {
                    clearInterval(timer);
                  }
                }, 50);
              } else {
                const originalText = cell.textContent;
                cell.textContent = "0";
                animateCounter(cell, value);
              }
            }
          });
          metricsObserver.unobserve(entry.target);
        }
      });
    },
    { threshold: 0.5 },
  );

  const metricsTable = document.querySelector(".metrics-table table");
  if (metricsTable) {
    metricsObserver.observe(metricsTable);
  }

  // Add dark mode toggle
  const createDarkModeToggle = () => {
    const toggle = document.createElement("div");
    toggle.className = "dark-mode-toggle";
    toggle.innerHTML = '<i class="fas fa-moon"></i>';
    toggle.style.position = "fixed";
    toggle.style.bottom = "20px";
    toggle.style.right = "20px";
    toggle.style.backgroundColor = "var(--primary-color)";
    toggle.style.color = "white";
    toggle.style.width = "50px";
    toggle.style.height = "50px";
    toggle.style.borderRadius = "50%";
    toggle.style.display = "flex";
    toggle.style.alignItems = "center";
    toggle.style.justifyContent = "center";
    toggle.style.cursor = "pointer";
    toggle.style.boxShadow = "0 2px 10px rgba(0, 0, 0, 0.2)";
    toggle.style.zIndex = "999";
    toggle.style.transition = "all 0.3s ease";

    document.body.appendChild(toggle);

    toggle.addEventListener("click", () => {
      document.body.classList.toggle("dark-mode");
      const icon = toggle.querySelector("i");
      if (document.body.classList.contains("dark-mode")) {
        icon.className = "fas fa-sun";
        toggle.style.backgroundColor = "#ffd166";
        toggle.style.color = "#1a1a2e";
      } else {
        icon.className = "fas fa-moon";
        toggle.style.backgroundColor = "var(--primary-color)";
        toggle.style.color = "white";
      }
    });
  };

  createDarkModeToggle();
});
