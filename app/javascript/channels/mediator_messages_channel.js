import consumer from "channels/consumer";

// Track if we've already scrolled on initial load for this conversation
let hasScrolledOnLoad = new Set();

document.addEventListener("turbo:load", () => {
  const messagesContainer = document.querySelector('.message-list-container');
  document.querySelectorAll(".mediator-chat-box").forEach((box) => {
    const conversationId = box.dataset.conversationId;
    const currentUserId = box.dataset.userId;
    const messagesList = box.querySelector(".message-list");

    if (!conversationId || !currentUserId || !messagesList) return;
    
    // Select correct chatbox for scrolling from mediator perspective
    const containerSelector = box.classList.contains("tenant-message-list-container")
      ? ".tenant-message-list-container"
      : ".landlord-message-list-container";

    const messagesContainer = document.querySelector(containerSelector);

    if (!messagesContainer) return;

    // Cleanup old subscriptions
    consumer.subscriptions.subscriptions.forEach((subscription) => {
      if (subscription.identifier.includes(`"conversation_id":"${conversationId}"`)) {
        consumer.subscriptions.remove(subscription);
      }
    });

    // Check if subscription already exists
    const existing = consumer.subscriptions.subscriptions.find((subscription) =>
      subscription.identifier.includes(`"conversation_id":"${conversationId}"`)
    );

    if (!existing) {
      consumer.subscriptions.create(
        { channel: "MediatorMessagesChannel", conversation_id: conversationId },
        {
          connected() {
            console.log(`MediatorMessagesChannel: Connected to ${conversationId}`);
          },

          disconnected() {
            console.log(`MediatorMessagesChannel: Disconnected from ${conversationId}`);
          },

          received(data) {
            const isSender = data.sender_id.toString() === currentUserId;
            const isRecipient = data.recipient_id.toString() === currentUserId;

            if (!isSender && !isRecipient) return;

            const messageClass = isSender ? "sent" : "received";
            const formattedRole = (data.sender_role || "").toString().replace(/_/g, " ");
            const senderName = data.sender_name || (isSender ? "You" : formattedRole || "Participant");
            const messageHtml = `
              <div class="chat-message ${messageClass}" data-message-id="${data.message_id}" data-sender-role="${formattedRole}" data-sender-id="${data.sender_id}" data-current-user-id="${currentUserId}">
                <div class="message-bubble">
                  <div class="message-meta">
                    <span class="message-author">${senderName}</span>
                    ${formattedRole ? `<span class="message-role">${formattedRole}</span>` : ""}
                  </div>
                  <p class="message-content">${data.contents}</p>
                  <small class="message-timestamp">${data.message_date}</small>
                </div>
              </div>
            `;

            messagesList.insertAdjacentHTML("beforeend", messageHtml);
            console.log("message sent, Scrolling to bottom of:", messagesList);
            // Instantly scroll to bottom
            messagesContainer.scrollTop = messagesContainer.scrollHeight;

            // Apply entering animation to the new message
            const newMessageElement = messagesList.lastElementChild;
            if (newMessageElement) {
              newMessageElement.classList.add("is-entering");
              newMessageElement.addEventListener("animationend", () => {
                newMessageElement.classList.remove("is-entering");
              }, { once: true });
            }
          }
        }
      );
    }

    // Scroll to bottom ONLY on first true page load
    console.log("page load, Scrolling to bottom of:", messagesList);
    if (!hasScrolledOnLoad.has(conversationId)) {
      hasScrolledOnLoad.add(conversationId);
      messagesContainer.classList.add("use-smooth-scroll");
      requestAnimationFrame(() => {
        messagesContainer.scrollTo({
          top: messagesContainer.scrollHeight,
          behavior: "smooth"
        });
        setTimeout(() => {
          messagesContainer.classList.remove("use-smooth-scroll");
        }, 450);
      });
    } else {
      // On subsequent turbo:load events, just jump to bottom instantly
      messagesContainer.scrollTop = messagesContainer.scrollHeight;
    }
  });
});

// Clear the tracking when navigating away
document.addEventListener('turbo:before-visit', () => {
  hasScrolledOnLoad.clear();
});
