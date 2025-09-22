import React, { createContext, useEffect, useRef } from "react";

import { Env } from "environment";

export const WebSocketContext = createContext<WebSocket | null>(null);

export function WebSocketProvider({ children }: { children: React.ReactNode }) {
  const socketRef = useRef<WebSocket | null>(null);

  useEffect(() => {
    const socket = new WebSocket(Env.WS_URL);

    socketRef.current = socket;

    socket.onopen = () => console.log("Connected to WebSocket server");
    socket.onmessage = (event) => console.log("Message:", event.data);
    socket.onclose = () => console.log("Disconnected");

    return () => socket.close();
  }, []);

  return (
    <WebSocketContext.Provider value={socketRef.current}>
      {children}
    </WebSocketContext.Provider>
  );
}