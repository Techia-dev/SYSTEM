import { formatDate } from "@techia/utils";

export default function Home() {
  return (
    <main>
      {formatDate(new Date())}
    </main>
  );
}