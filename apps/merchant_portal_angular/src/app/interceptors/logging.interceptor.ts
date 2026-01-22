import { Injectable } from '@angular/core';
import {
  HttpInterceptor,
  HttpRequest,
  HttpHandler,
  HttpEvent,
  HttpResponse
} from '@angular/common/http';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';
import { LoggingService } from '../services/logging.service';

@Injectable({ providedIn: 'root' })
export class LoggingInterceptor implements HttpInterceptor {
  private requestCounter = 0;

  constructor(private loggingService: LoggingService) {}

  intercept(
    request: HttpRequest<any>,
    next: HttpHandler
  ): Observable<HttpEvent<any>> {
    const requestId = ++this.requestCounter;
    const startTime = performance.now();

    // Log request
    this.loggingService.debug(
      `[#${requestId}] ${request.method} ${request.url}`,
      {
        headers: this.sanitizeHeaders(request.headers),
        body: request.body
      }
    );

    return next.handle(request).pipe(
      tap({
        next: (event: HttpEvent<any>) => {
          if (event instanceof HttpResponse) {
            const duration = performance.now() - startTime;
            this.loggingService.info(
              `[#${requestId}] Response: ${event.status} (${duration.toFixed(2)}ms)`,
              {
                url: request.url,
                statusText: event.statusText,
                body: event.body
              }
            );
          }
        },
        error: (error) => {
          const duration = performance.now() - startTime;
          this.loggingService.error(
            `[#${requestId}] Request failed after ${duration.toFixed(2)}ms`,
            {
              url: request.url,
              method: request.method,
              error: error.message
            }
          );
        }
      })
    );
  }

  private sanitizeHeaders(headers: any): any {
    const sanitized: any = {};
    headers.keys().forEach((key: string) => {
      if (
        key.toLowerCase() === 'authorization' ||
        key.toLowerCase() === 'x-api-key'
      ) {
        sanitized[key] = '***REDACTED***';
      } else {
        sanitized[key] = headers.get(key);
      }
    });
    return sanitized;
  }
}
