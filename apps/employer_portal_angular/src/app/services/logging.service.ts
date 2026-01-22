import { Injectable } from '@angular/core';

export interface LogEntry {
  timestamp: Date;
  level: 'DEBUG' | 'INFO' | 'WARN' | 'ERROR';
  message: string;
  context?: any;
  stack?: string;
}

@Injectable({
  providedIn: 'root'
})
export class LoggingService {
  private logs: LogEntry[] = [];
  private maxLogs = 1000;

  log(level: LogEntry['level'], message: string, context?: any, stack?: string) {
    const entry: LogEntry = {
      timestamp: new Date(),
      level,
      message,
      context,
      stack
    };

    this.logs.push(entry);
    if (this.logs.length > this.maxLogs) {
      this.logs.shift();
    }

    // Also log to console in dev mode
    const prefix = `[${entry.timestamp.toISOString()}] [${level}]`;
    switch (level) {
      case 'DEBUG':
        console.debug(prefix, message, context);
        break;
      case 'INFO':
        console.info(prefix, message, context);
        break;
      case 'WARN':
        console.warn(prefix, message, context);
        break;
      case 'ERROR':
        console.error(prefix, message, context, stack);
        break;
    }
  }

  debug(message: string, context?: any) {
    this.log('DEBUG', message, context);
  }

  info(message: string, context?: any) {
    this.log('INFO', message, context);
  }

  warn(message: string, context?: any) {
    this.log('WARN', message, context);
  }

  error(message: string, context?: any, stack?: string) {
    this.log('ERROR', message, context, stack);
  }

  getLogs(): LogEntry[] {
    return [...this.logs];
  }

  clearLogs(): void {
    this.logs = [];
  }

  exportLogs(): string {
    return JSON.stringify(this.logs, null, 2);
  }
}
