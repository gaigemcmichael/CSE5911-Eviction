const MIN_HEIGHT = "38px";
let negotiationSubmitListenerBound = false;

const setupTextareaAutoExpand = () => {
  const textareas = document.querySelectorAll(".message-textarea");

  textareas.forEach((textarea) => {
    if (textarea.dataset.autoExpandInitialized === "true") return;

    const autoExpand = () => {
      if (!textarea.value.trim()) {
        textarea.style.height = MIN_HEIGHT;
        return;
      }

      textarea.style.height = MIN_HEIGHT;
      const newHeight = Math.min(textarea.scrollHeight, 160);
      textarea.style.height = `${newHeight}px`;
    };

    textarea.addEventListener("input", autoExpand);
    textarea.dataset.autoExpandInitialized = "true";

    if (textarea.value.trim()) {
      autoExpand();
    }
  });
};

const getComposerElements = (form) => {
  const textarea = form.querySelector(".message-textarea");
  const submitButton = form.querySelector(".send-msg-btn");
  const attachmentSelect = form.querySelector("select[name$='[file_id]'], select[name='file_id']");

  const hasAttachment = () =>
    Boolean(attachmentSelect && attachmentSelect.value && attachmentSelect.value.trim().length > 0);

  const hasMessageText = () => Boolean(textarea && textarea.value.trim().length > 0);

  const canSend = () => hasMessageText() || hasAttachment();

  const updateButtonState = () => {
    if (!submitButton) return;
    const enabled = canSend();
    submitButton.disabled = !enabled;
    submitButton.classList.toggle("is-ready", enabled);
  };

  return { textarea, submitButton, attachmentSelect, hasAttachment, hasMessageText, canSend, updateButtonState };
};

const setupComposerForm = () => {
  const form = document.querySelector("#new_message_form form");
  if (!form || form.dataset.composerInitialized === "true") return;

  const elements = getComposerElements(form);
  form.dataset.composerInitialized = "true";

  const { textarea, attachmentSelect, updateButtonState, canSend } = elements;

  if (textarea) {
    textarea.addEventListener("input", updateButtonState);

    textarea.addEventListener("keydown", (event) => {
      if (event.key === "Enter" && !event.shiftKey && canSend()) {
        event.preventDefault();
        if (typeof form.requestSubmit === "function") {
          form.requestSubmit();
        } else {
          form.dispatchEvent(new Event("submit", { bubbles: true, cancelable: true }));
        }
      }
    });
  }

    if (attachmentSelect) {
      attachmentSelect.addEventListener("change", updateButtonState);
    }

  form.addEventListener("reset", () => {
    requestAnimationFrame(() => {
      updateButtonState();
      if (textarea) {
        textarea.style.height = MIN_HEIGHT;
      }
    });
  });

  updateButtonState();
};

const handleNegotiationSubmit = (event) => {
  const form = event.target.closest("#new_message_form form");
  if (!form) return;

  event.preventDefault();

  const elements = getComposerElements(form);
  const { textarea, submitButton, attachmentSelect, canSend, updateButtonState } = elements;

  if (!canSend()) {
    updateButtonState();
    return;
  }

  if (submitButton && submitButton.disabled) return;

  if (submitButton) {
    submitButton.disabled = true;
    submitButton.classList.remove("is-ready");
  }

  fetch(form.action, {
    method: "POST",
    headers: {
      "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
      "Accept": "application/json"
    },
    body: new FormData(form)
  })
    .then((response) => {
      if (!response.ok) throw new Error("Failed to send message");
      return response.json();
    })
    .then(() => {
      if (textarea) {
        textarea.value = "";
        textarea.style.height = MIN_HEIGHT;
      }
      if (attachmentSelect) {
        attachmentSelect.value = "";
      }
      form.reset();
      updateButtonState();
    })
    .catch((error) => {
      console.error("Error sending message:", error);
      if (submitButton) {
        submitButton.disabled = false;
        updateButtonState();
      }
    });
};

document.addEventListener("turbo:load", () => {
  setupTextareaAutoExpand();
  setupComposerForm();

  if (!negotiationSubmitListenerBound) {
    document.addEventListener("submit", handleNegotiationSubmit);
    negotiationSubmitListenerBound = true;
  }
});
