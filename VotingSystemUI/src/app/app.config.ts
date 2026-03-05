import { ApplicationConfig, provideZonelessChangeDetection } from '@angular/core';
import { provideRouter } from '@angular/router';
import { routes } from './app.routes';
import { provideHttpClient } from '@angular/common/http';

export const appConfig: ApplicationConfig = {
  providers: [
    // The official, stable zoneless engine!
    provideZonelessChangeDetection(),
    provideRouter(routes),
    provideHttpClient()
  ]
};