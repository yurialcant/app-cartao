import { Injectable } from '@angular/core';
import {
  HttpInterceptor,
  HttpRequest,
  HttpHandler,
  HttpEvent,
  HttpErrorResponse
} from '@angular/common/http';
import { Observable, throwError, timer } from 'rxjs';
import { catchError, retry, retryWhen, mergeMap, finalize } from 'rxjs/operators';
import { LoggingService } from '../services/logging.service';

@Injectable({ providedIn: 'root' })
export class HttpErrorInterceptor implements HttpInterceptor {
  private maxRetries = 3;
  private retryDelay = 1000; // ms

  constructor(private loggingService: LoggingService) {}

  intercept(
    request: HttpRequest<any>,
    next: HttpHandler
  ): Observable<HttpEvent<any>> {
    const startTime = performance.now();

    return next.handle(request).pipe(
      retryWhen(errors =>
        errors.pipe(
          mergeMap((error, index) => {
            if (
              index < this.maxRetries &&
              this.isRetryableError(error)
            ) {
              const delay = this.retryDelay * Math.pow(2, index);
              this.loggingService.warn(
                `Retrying request (attempt ${index + 1}/${this.maxRetries})`,
                { url: request.url, delayMs: delay }
              );
              return timer(delay);
            }
            return throwError(() => error);
          })
        )
      ),
      finalize(() => {
        const duration = performance.now() - startTime;
        this.loggingService.debug(`${request.method} ${request.url}`, {
          durationMs: duration
        });
      }),
      catchError((error: HttpErrorResponse) => {
        return this.handleError(error, request);
      })
    );
  }

  private isRetryableError(error: any): boolean {
    // Don't retry 4xx errors (except 408, 429) and authentication errors
    if (error instanceof HttpErrorResponse) {
      if (error.status >= 400 && error.status < 500) {
        // Retry on timeout (408) and rate limit (429)
        return error.status === 408 || error.status === 429;
      }
      // Retry on 5xx and connection errors
      return error.status >= 500 || error.status === 0;
    }
    return false;
  }

  private handleError(
    error: HttpErrorResponse,
    request: HttpRequest<any>
  ): Observable<never> {
    let errorMessage = 'An error occurred';
    let userFriendlyMessage = 'An error occurred';

    if (error.error instanceof ErrorEvent) {
      // Client-side error
      errorMessage = `Client Error: ${error.error.message}`;
      userFriendlyMessage = 'Network error. Please check your connection.';
    } else {
      // Server-side error
      const status = error.status;

      switch (status) {
        case 0:
          errorMessage = 'Network error - unable to reach server';
          userFriendlyMessage = 'Unable to connect to server. Please check your internet connection.';
          break;
        case 400:
          errorMessage = `Bad Request: ${error.error?.message || ''}`;
          userFriendlyMessage = `Invalid request: ${error.error?.message || 'Please check your input'}`;
          break;
        case 401:
          errorMessage = 'Unauthorized - session expired';
          userFriendlyMessage = 'Your session has expired. Please login again.';
          // Trigger logout
          window.location.href = '/login';
          break;
        case 403:
          errorMessage = 'Forbidden - insufficient permissions';
          userFriendlyMessage = 'You do not have permission to perform this action.';
          break;
        case 404:
          errorMessage = 'Resource not found';
          userFriendlyMessage = 'The requested resource was not found.';
          break;
        case 408:
          errorMessage = 'Request timeout';
          userFriendlyMessage = 'Request timed out. Please try again.';
          break;
        case 429:
          errorMessage = 'Too many requests';
          userFriendlyMessage = 'Too many requests. Please slow down and try again.';
          break;
        case 500:
          errorMessage = 'Internal Server Error';
          userFriendlyMessage = 'Server error. Please try again later.';
          break;
        case 502:
          errorMessage = 'Bad Gateway';
          userFriendlyMessage = 'Server is temporarily unavailable. Please try again.';
          break;
        case 503:
          errorMessage = 'Service Unavailable';
          userFriendlyMessage = 'Service is temporarily unavailable. Please try again later.';
          break;
        default:
          errorMessage = `HTTP Error ${status}: ${error.statusText}`;
          userFriendlyMessage = `Error: ${error.statusText || 'Unknown error occurred'}`;
      }
    }

    // Log the error
    this.loggingService.error(errorMessage, {
      url: request.url,
      method: request.method,
      status: error.status,
      statusText: error.statusText,
      userMessage: userFriendlyMessage
    });

    // Return error with user-friendly message
    const errorObj = {
      status: error.status,
      message: errorMessage,
      userFriendlyMessage,
      timestamp: new Date()
    };

    return throwError(() => errorObj);
  }
}
