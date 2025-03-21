document.addEventListener("turbo:load", () => {
    document.querySelectorAll(".mediator-message-form").forEach((form) => {
      form.addEventListener("submit", (e) => {
        e.preventDefault();
  
        const input = form.querySelector("textarea");
        const submitButton = form.querySelector("input[type='submit']");
  
        if (submitButton.disabled || !input.value.trim()) return;
  
        submitButton.disabled = true;
  
        fetch(form.action, {
          method: "POST",
          headers: {
            "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content,
            "Accept": "application/json"
          },
          body: new FormData(form)
        })
          .then((response) => response.json())
          .then((data) => {
            input.value = "";
            form.reset();
          })
          .catch((error) => {
            console.error("Error sending message:", error);
          })
          .finally(() => {
            submitButton.disabled = false;
          });
      });
    });
  });
  