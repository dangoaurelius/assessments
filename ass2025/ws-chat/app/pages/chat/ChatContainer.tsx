import { useContext, useState } from "react";
import { Chat } from './Chat';

import { WebSocketProvider, WebSocketContext } from '../../utils/providers/WebSocketProvider';

export function ChatContainer() {
    const socket = useContext(WebSocketContext);

  const sendMessage = () => {
    socket?.send("Hello from ChatContainer");
  };
  
  return (
    <WebSocketProvider>
      <Chat onSendMessagePress={sendMessage} />
    </WebSocketProvider>
  );
}