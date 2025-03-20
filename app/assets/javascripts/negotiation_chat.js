document.addEventListener("turbo:load", () => {
    const form = document.querySelector("#new_message_form form");
  
    if (!form) return; // Ensure the form exists before proceeding
  
    form.removeEventListener("submit", handleSubmit);
    form.addEventListener("submit", handleSubmit);
  });
  
  function handleSubmit(e) {
    e.preventDefault();
    
    const form = e.target;
    const input = document.getElementById("message_contents");
    const submitButton = form.querySelector("input[type='submit']");
  
    if (submitButton.disabled) {
      console.warn("Message submission blocked: already in progress.");
      return;
    }
    submitButton.disabled = true;
  
    fetch(form.action, {
      method: "POST",
      headers: { "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content },
      body: new FormData(form)
    }).then(response => {
      submitButton.disabled = false; // Re-enable after response
      if (response.status === 204) {
        input.value = "";
        form.reset();
      } else if (response.ok) {
        return response.json().then(data => {
          input.value = "";
          form.reset();
        });
      } else {
        return response.json().then(data => {
          throw new Error(data.error || "Failed to send message.");
        });
      }
    }).catch(error => {
      submitButton.disabled = false; // Re-enable on error
      console.error("Error sending message:", error);
    });
  }
  