(() => {
  const URL = "http://127.0.0.1:27182/";
  const TAB_BAR = 22;
  const PEAK_KEY = "cursor-i3-peak-height";

  let peak = Number(sessionStorage.getItem(PEAK_KEY) || 0);

  const setGrouped = (grouped) => {
    document.body.classList.toggle("i3-grouped", grouped);
  };

  const syncFromHeight = () => {
    const height = window.outerHeight;
    if (height > peak) {
      peak = height;
      sessionStorage.setItem(PEAK_KEY, String(peak));
    }
    setGrouped(peak - height >= TAB_BAR);
  };

  const sync = () => {
    fetch(URL, { cache: "no-store" })
      .then((response) => response.text())
      .then((value) => setGrouped(value.trim() === "1"))
      .catch(() => syncFromHeight());
  };

  sync();
  setInterval(sync, 200);
  window.addEventListener("resize", sync);
  window.addEventListener("focus", sync);
})();
