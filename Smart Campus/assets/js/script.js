document.addEventListener("DOMContentLoaded", () => {
  console.log("SmartCampus Front-End Loaded 🚀");

  // Logout confirmation
  const logoutButtons = document.querySelectorAll("a[href='../index.html'], a[href='../../index.html']");
  logoutButtons.forEach((btn) => {
    btn.addEventListener("click", (e) => {
      const confirmLogout = confirm("Yakin ingin logout dari SmartCampus?");
      if (!confirmLogout) e.preventDefault();
    });
  });
});
