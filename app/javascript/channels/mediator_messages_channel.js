import consumer from "channels/consumer";

document.addEventListener("turbo:load", () => {
  document.querySelectorAll(".mediator-chat-box").forEach((box) => {
    const conversationId = box.dataset.conversationId;
    const currentUserId = box.dataset.userId;
    const messagesList = box.querySelector(".message-list");

    if (!conversationId || !currentUserId || !messagesList) return;

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
            const messageHtml = `
              <div class="chat-message ${messageClass}">
                <div class="message-bubble">
                  <p class="message-content">${data.contents}</p>
                  <small class="message-timestamp">${data.message_date}</small>
                </div>
              </div>
            `;

            messagesList.insertAdjacentHTML("beforeend", messageHtml);
            messagesList.scrollTo({
              top: messagesList.scrollHeight,
              behavior: "smooth"
            });
          }
        }
      );
    }

    // Scroll to bottom on load
    messagesList.scrollTo({
      top: messagesList.scrollHeight,
      behavior: "auto"
    });
  });
});
