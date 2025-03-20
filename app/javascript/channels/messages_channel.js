import consumer from "channels/consumer";

document.addEventListener('turbo:load', () => {
  const messagesContainer = document.querySelector('.message-list-container'); // Correctly target the scrollable container
  const messagesList = document.getElementById('messages'); // Message list within the container

  if (messagesContainer && messagesList) {
    const conversationId = messagesList.dataset.conversationId;
    const currentUserId = messagesList.dataset.currentUserId;

    if (conversationId) {
      console.log(`Checking for existing subscriptions before subscribing to conversation ID: ${conversationId}`);
      
      console.log("Active subscriptions before cleanup:", consumer.subscriptions.subscriptions);

      // Unsubscribe from existing subscriptions to avoid double messages
      consumer.subscriptions.subscriptions.forEach((subscription) => {
        if (subscription.identifier.includes(`"conversation_id":"${conversationId}"`)) {
          console.log("Removing duplicate subscription:", subscription);
          consumer.subscriptions.remove(subscription);
        }
      });

      console.log("Active subscriptions after cleanup:", consumer.subscriptions.subscriptions);

      // **Check if a subscription already exists**
      const existingSubscription = consumer.subscriptions.subscriptions.find((subscription) =>
        subscription.identifier.includes(`"conversation_id":"${conversationId}"`)
      );
      
      if (!existingSubscription) {
        consumer.subscriptions.create({ channel: "MessagesChannel", conversation_id: conversationId }, {
          initialized() {
            console.log(`Initializing subscription for conversation ID: ${conversationId}`);
          },
          connected() {
            console.log(`Connected to conversation ID: ${conversationId}`);
          },
          received(data) {
            if (data.type === 'mediator_assigned') {
              const messageFormContainer = document.getElementById('new_message_form');
              if (messageFormContainer) {
                messageFormContainer.style.display = 'none';
                console.log("Mediator assigned, message input form hidden.");
              }
              return; // Stop further processing
            }

            const isSender = data.sender_id.toString() === currentUserId;
            const isRecipient = data.recipient_id.toString() === currentUserId;
            
            if (isSender || isRecipient) {
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
          }
        });
      }
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

document.addEventListener('turbo:load', () => {
  if (window.mediatorAssigned === true || window.mediatorAssigned === 'true') {
    const messageFormContainer = document.getElementById('new_message_form');
    if (messageFormContainer) {
      messageFormContainer.style.display = 'none';
      console.log("Mediator already assigned, message input form hidden.");
    }
  }
});
