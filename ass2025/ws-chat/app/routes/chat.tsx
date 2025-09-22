import type { Route } from "./+types/chat";

import Chat from "../pages/chat";

export function meta({}: Route.MetaArgs) {
  return [
    { title: "Chat | App" },
    { name: "description", content: "Chat placeholder page" },
  ];
}

export default function ChatRoute() {
  return <Chat />;
}
