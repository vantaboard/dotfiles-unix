(() => {
  const URL = "http://127.0.0.1:27182/";

  const sync = () => {
    fetch(URL, { cache: "no-store" })
      .then((response) => response.text())
      .then((value) => {
        document.body.classList.toggle("i3-grouped", value.trim() === "1");
      })
      .catch(() => {});
  };

  sync();
  setInterval(sync, 200);
})();
