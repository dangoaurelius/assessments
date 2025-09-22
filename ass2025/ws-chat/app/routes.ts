import { type RouteConfig, index, route } from "@react-router/dev/routes";

export default [
  route("chat", "routes/chat.tsx"),
  index("routes/home.tsx"),
] satisfies RouteConfig;
