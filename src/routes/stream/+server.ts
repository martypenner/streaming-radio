import { env } from '$env/dynamic/private';
import type { RequestHandler } from './$types';

export const GET: RequestHandler = async ({ fetch }) => {
	const stream = await fetch(env.ICECAST_URL);
	const response = new Response(stream.body, stream);
	response.headers.set('Cache-Control', 'no-store, no-cache, private');

	return response;
};
