import { spawn, type ChildProcessWithoutNullStreams } from 'child_process';
import readline from 'readline';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const workerScript = path.join(__dirname, '..', 'hy_mt_worker.py');
const workerCwd = path.join(__dirname, '..');

let worker: ChildProcessWithoutNullStreams | null = null;
let readyPromise: Promise<void> | null = null;

type QueueItem = {
  payload: { text: string; source_lang: string; target_lang: string };
  resolve: (translation: string) => void;
  reject: (error: Error) => void;
};

const queue: QueueItem[] = [];
let processing = false;
let current: QueueItem | null = null;

function startWorker(): Promise<void> {
  if (readyPromise) return readyPromise;

  readyPromise = new Promise((resolve, reject) => {
    worker = spawn('python', [workerScript], {
      cwd: workerCwd,
      stdio: ['pipe', 'pipe', 'pipe'],
    });

    const timeout = setTimeout(() => {
      reject(new Error('HY-MT worker failed to start within 120s'));
    }, 120_000);

    worker.stderr.on('data', (chunk: Buffer) => {
      const text = chunk.toString();
      process.stderr.write(text);
      if (text.includes('HY_MT_READY')) {
        clearTimeout(timeout);
        resolve();
      }
    });

    const rl = readline.createInterface({ input: worker!.stdout });
    rl.on('line', (line) => {
      processing = false;
      const pending = current;
      current = null;
      if (!pending) return;

      try {
        const data = JSON.parse(line) as { translation?: string; error?: string };
        if (data.error) pending.reject(new Error(data.error));
        else pending.resolve(data.translation ?? '');
      } catch (err) {
        pending.reject(err instanceof Error ? err : new Error(String(err)));
      }

      processQueue();
    });

    worker.on('error', (err) => {
      clearTimeout(timeout);
      reject(err);
    });

    worker.on('exit', (code) => {
      worker = null;
      readyPromise = null;
      if (current) {
        current.reject(new Error(`HY-MT worker exited (code ${code})`));
        current = null;
      }
      while (queue.length > 0) {
        queue.shift()?.reject(new Error('HY-MT worker exited'));
      }
    });
  });

  return readyPromise;
}

function processQueue(): void {
  if (processing || !worker?.stdin.writable || queue.length === 0) return;

  processing = true;
  current = queue.shift()!;
  worker.stdin.write(`${JSON.stringify(current.payload)}\n`);
}

export async function translateWithHyMt(
  text: string,
  sourceLang: string,
  targetLang: string,
): Promise<string> {
  await startWorker();

  return new Promise((resolve, reject) => {
    queue.push({
      payload: {
        text,
        source_lang: sourceLang,
        target_lang: targetLang,
      },
      resolve,
      reject,
    });
    processQueue();
  });
}

export function shutdownHyMtWorker(): void {
  worker?.kill();
  worker = null;
  readyPromise = null;
}

process.on('exit', shutdownHyMtWorker);
