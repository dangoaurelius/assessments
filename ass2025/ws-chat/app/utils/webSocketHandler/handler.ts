import { use, useMemo, useEffect, useRef } from "react"; 

export const useWebSocket = () => {

    useEffect(() => {
    const socket = new WebSocket("ws://localhost:3001");
    

    socket.onopen = () => console.log("Connected to WebSocket server");
    socket.onmessage = (event) => console.log("Message:", event.data);
    socket.onclose = () => console.log("Disconnected");

    return () => socket.close();
  }, []);
  
}