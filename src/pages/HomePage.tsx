import { useQuery } from '@tanstack/react-query';
import { ApiError, apiFetch } from '../api/client';

type SampleResponse = {
  message: string;
  status: string;
};

export function HomePage() {
  const sampleQuery = useQuery<SampleResponse, ApiError>({
    queryKey: ['sample'],
    queryFn: () => apiFetch<SampleResponse>('/sample'),
    retry: false,
  });

  return (
    <>
      <section className="hero" aria-labelledby="home-title">
        <p className="eyebrow">Paved-road frontend</p>
        <h1 id="home-title">Build an Acme Bank React experience on a secure baseline.</h1>
        <p>This starter is intentionally small: React Router for pages, Tanstack Query for server state, and an nginx container that can join an existing Acme Bank Azure environment.</p>
      </section>
      <section className="card" aria-labelledby="api-sample-title">
        <h2 id="api-sample-title">BFF API sample</h2>
        {sampleQuery.isLoading && <p className="status info">Checking the sample endpoint…</p>}
        {sampleQuery.isError && sampleQuery.error.status === 404 && (
          <p className="status warning">No backend sample endpoint is available yet. Add one to your BFF or replace this query with your feature API.</p>
        )}
        {sampleQuery.isError && sampleQuery.error.status !== 404 && (
          <p className="status error">The sample endpoint returned {sampleQuery.error.status}. Check your local BFF or deployed BFF_BASE_URL setting.</p>
        )}
        {sampleQuery.isSuccess && (
          <p className="status info">
            {sampleQuery.data.message} <strong>{sampleQuery.data.status}</strong>
          </p>
        )}
      </section>
    </>
  );
}
