type ChatProps = {
  onSendMessagePress: () => void;
};


export function Chat(props: ChatProps) {
  return (
    <main className="flex items-center justify-center pt-16 pb-4">
      <div className="flex-1 flex flex-col items-center gap-16 min-h-0">
        <header className="flex flex-col items-center gap-9">
          <div className="w-[500px] max-w-[100vw] p-4">
            Chat App example
          </div>

          <div className="max-w-[300px] w-full space-y-6 px-4">
            <button
              className="rounded bg-blue-500 text-white px-4 py-2 hover:bg-blue-600"
              onClick={props.onSendMessagePress}>
              Send Test Message
            </button>
          </div>
        </header>
      </div>

    </main>
  );
}
