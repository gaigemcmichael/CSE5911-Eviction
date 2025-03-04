import consumer from "channels/consumer"

document.addEventListener('turbo:load', () => {
  const messagesContainer = document.querySelector('.message-list-container'); // Correctly target the scrollable container
  const messagesList = document.getElementById('messages'); // Message list within the container

  if (messagesContainer && messagesList) {
    const conversationId = messagesList.dataset.conversationId;
    const currentUserId = messagesList.dataset.currentUserId;

    if (conversationId) {
      console.log(`Subscribing to conversation ID: ${conversationId}`);
      
      // Unsubscribe from existing subscriptions to avoid double messages
      consumer.subscriptions.subscriptions.forEach((subscription) => {
        consumer.subscriptions.remove(subscription);
      });

      consumer.subscriptions.create({ channel: "MessagesChannel", conversation_id: conversationId }, {
        received(data) {
          const isSender = data.sender_id.toString() === currentUserId;
          const messageClass = isSender ? 'sent' : 'received';

          const messageHtml = `
            <div class="chat-message ${messageClass}" data-message-id="${data.message_id}">
              <div class="message-bubble">
                <p class="message-content">${data.contents}</p>
                <small class="message-timestamp">${data.message_date}</small>
              </div>
            </div>
          `;

          messagesList.insertAdjacentHTML('beforeend', messageHtml);

          // Automatically scroll to the bottom of the message list container
          messagesContainer.scrollTo({
            top: messagesContainer.scrollHeight,
            behavior: 'smooth' // Smooth scrolling animation
          });
        }
      });

      // Initial scroll to bottom when the page loads
      messagesContainer.scrollTo({
        top: messagesContainer.scrollHeight,
        behavior: 'auto' // Instantly jumps to bottom on load
      });
    } else {
      console.error("No conversation ID found in message list!");
    }
  }
});
