import { afterEach, describe, expect, it, vi } from 'vitest';
import { apiFetch, apiUrl } from './client';

describe('apiUrl', () => {
  it('prefixes paths with the API base path', () => {
    expect(apiUrl('/sample')).toBe('/api/sample');
    expect(apiUrl('sample')).toBe('/api/sample');
  });
});

describe('apiFetch', () => {
  afterEach(() => {
    vi.unstubAllGlobals();
  });

  it('returns JSON for successful responses', async () => {
    const fetchMock = vi.fn<typeof fetch>().mockResolvedValue(new Response(JSON.stringify({ status: 'ok' }), { status: 200 }));
    vi.stubGlobal('fetch', fetchMock);

    await expect(apiFetch<{ status: string }>('/sample')).resolves.toEqual({ status: 'ok' });
    expect(fetchMock).toHaveBeenCalledWith('/api/sample', {});
  });

  it('throws ApiError for non-2xx responses', async () => {
    const fetchMock = vi.fn<typeof fetch>().mockResolvedValue(new Response('Not found', { status: 404, statusText: 'Not Found' }));
    vi.stubGlobal('fetch', fetchMock);

    await expect(apiFetch('/missing')).rejects.toMatchObject({
      name: 'ApiError',
      status: 404,
      message: 'Not Found',
    });
  });
});
