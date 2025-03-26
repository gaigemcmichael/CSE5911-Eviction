document.addEventListener("turbo:load", () => {
  document.addEventListener("submit", (e) => {
    const form = e.target.closest("#new_message_form form");
    if (form) {
      e.preventDefault();

      const input = form.querySelector("#message_contents");
      const submitButton = form.querySelector("input[type='submit']");
      if (submitButton.disabled) return;

      submitButton.disabled = true;

      fetch(form.action, {
        method: "POST",
        headers: {
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
          "Accept": "application/json"
        },
        body: new FormData(form)
      })
      .then(response => response.json())
      .then(data => {
        input.value = "";
        form.reset();
        submitButton.disabled = false;
      })
      .catch(error => {
        submitButton.disabled = false;
        console.error("Error sending message:", error);
      });
    }
  });
});
