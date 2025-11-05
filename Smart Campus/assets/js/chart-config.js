// Pastikan Chart.js sudah ditautkan di HTML sebelum script ini
document.addEventListener("DOMContentLoaded", () => {
  const ctx1 = document.getElementById("chartMahasiswa");
  if (ctx1) {
    new Chart(ctx1, {
      type: "bar",
      data: {
        labels: ["TI-3A", "TI-3B", "TI-3C", "TI-3D"],
        datasets: [{
          label: "Jumlah Mahasiswa",
          data: [35, 40, 38, 32],
          backgroundColor: "#00bcd4"
        }]
      },
      options: {
        responsive: true,
        scales: { y: { beginAtZero: true } }
      }
    });
  }

  const ctx2 = document.getElementById("chartAbsensi");
  if (ctx2) {
    new Chart(ctx2, {
      type: "line",
      data: {
        labels: ["Senin", "Selasa", "Rabu", "Kamis", "Jumat"],
        datasets: [{
          label: "Persentase Kehadiran",
          data: [90, 88, 92, 85, 95],
          borderColor: "#0097a7",
          fill: true,
          backgroundColor: "rgba(0,188,212,0.2)"
        }]
      },
      options: { responsive: true, tension: 0.4 }
    });
  }
});
