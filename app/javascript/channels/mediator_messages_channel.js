import consumer from "channels/consumer";

document.addEventListener("turbo:load", () => {
  document.querySelectorAll(".mediator-chat-box").forEach((box) => {
    const messagesList = box.querySelector(".message-list");
    const conversationId = box.dataset.conversationId;
    const currentUserId = box.dataset.userId;

    if (!conversationId || !messagesList) return;

    // Unsubscribe if already exists
    consumer.subscriptions.subscriptions.forEach((subscription) => {
      if (subscription.identifier.includes(`"conversation_id":"${conversationId}"`)) {
        consumer.subscriptions.remove(subscription);
      }
    });

    consumer.subscriptions.create(
      { channel: "MediatorMessagesChannel", conversation_id: conversationId },
      {
        received(data) {
          const isSender = data.sender_id.toString() === currentUserId;
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
  });
});
