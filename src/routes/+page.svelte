<script lang="ts">
	// Use logarithmic volume control to convert from the volume slider (0-100)
	// to the audio volume (0-1).
	const logarithmicVolume = (rawVolume: number) => {
		return Math.pow(rawVolume / 100, 2);
	};

	// This will trigger a new src on the audio element, causing to
	// essentially retry loading and playing.
	const resetSrc = () => {
		src = makeSrc();
	};

	// Set the audio source to the proxied Icecast stream,
	// with some extra cache-busting and a way to retry
	// after errors.
	const makeSrc = () => {
		return `/stream?bust=${Date.now()}`;
	};

	let ref: HTMLAudioElement;
	let time = 0;
	let paused = true;
	let muted = false;
	let rawVolume = 55;
	$: volume = logarithmicVolume(rawVolume);

	let src = makeSrc();
	let retry = false;

	type TimerId = ReturnType<typeof setTimeout>;
	let timerId: TimerId;
	$: if (retry) {
		timerId = setInterval(() => {
			console.log('busting audio src to retry loading');
			resetSrc();
		}, 2_000);
	} else {
		clearInterval(timerId);
	}
</script>

<svelte:head>
	<title>RPG Music</title>
</svelte:head>

<audio
	bind:this={ref}
	{src}
	{muted}
	bind:currentTime={time}
	bind:paused
	bind:volume
	on:play={() => {
		retry = false;

		// Seek to the end so no one gets left behind.
		const newTime = ref.duration;
		if (!Number.isNaN(newTime) && newTime !== Infinity) {
			time = newTime;
		}
	}}
	on:canplay={() => {
		retry = false;
	}}
	on:ended={() => {
		retry = true;
		paused = true;
		resetSrc();
	}}
	on:error={() => {
		console.log('Error playing audio:', ref.error);
		retry = true;
		paused = true;
	}}
/>

<div class="page">
	<div class="card">
		<div class="card-body">
			<h2 class="card-title">RPG Music</h2>
			<div>
				<div>
					<div class="now-playing-details">
						<div class="now-playing-art">
							<img src="/generic_song.jpg" alt="Album art" class="album-art" />
						</div>
						<div class="now-playing-main">
							<div>
								<h4 class="now-playing-title">DJ BroadBanned</h4>
							</div>
						</div>
					</div>

					<hr />

					<div class="radio-controls">
						<button
							type="button"
							class="play"
							aria-label={paused ? 'play' : 'pause'}
							on:click={() => {
								paused = !paused;
								if (!paused) {
									// Reset the src to ensure we seek right to the end before we have a duration.
									resetSrc();
								}
							}}
						>
							<svg
								xmlns="http://www.w3.org/2000/svg"
								height="3em"
								viewBox="0 0 512 512"
								fill="#2196f3"
							>
								{#if paused}
									<path
										d="M464 256A208 208 0 1 0 48 256a208 208 0 1 0 416 0zM0 256a256 256 0 1 1 512 0A256 256 0 1 1 0 256zM188.3 147.1c7.6-4.2 16.8-4.1 24.3 .5l144 88c7.1 4.4 11.5 12.1 11.5 20.5s-4.4 16.1-11.5 20.5l-144 88c-7.4 4.5-16.7 4.7-24.3 .5s-12.3-12.2-12.3-20.9V168c0-8.7 4.7-16.7 12.3-20.9z"
									/>
								{:else}
									<path
										d="M464 256A208 208 0 1 0 48 256a208 208 0 1 0 416 0zM0 256a256 256 0 1 1 512 0A256 256 0 1 1 0 256zm224-72V328c0 13.3-10.7 24-24 24s-24-10.7-24-24V184c0-13.3 10.7-24 24-24s24 10.7 24 24zm112 0V328c0 13.3-10.7 24-24 24s-24-10.7-24-24V184c0-13.3 10.7-24 24-24s24 10.7 24 24z"
									/>
								{/if}
							</svg>
						</button>

						<div class="w-1/3 flex align-center">
							<button
								type="button"
								aria-label="Mute"
								class="volume"
								on:click={() => {
									muted = !muted;
								}}
							>
								{#if rawVolume === 0 || muted}
									<svg xmlns="http://www.w3.org/2000/svg" height="2em" viewBox="0 0 576 512">
										<path
											d="M301.1 34.8C312.6 40 320 51.4 320 64V448c0 12.6-7.4 24-18.9 29.2s-25 3.1-34.4-5.3L131.8 352H64c-35.3 0-64-28.7-64-64V224c0-35.3 28.7-64 64-64h67.8L266.7 40.1c9.4-8.4 22.9-10.4 34.4-5.3zM425 167l55 55 55-55c9.4-9.4 24.6-9.4 33.9 0s9.4 24.6 0 33.9l-55 55 55 55c9.4 9.4 9.4 24.6 0 33.9s-24.6 9.4-33.9 0l-55-55-55 55c-9.4 9.4-24.6 9.4-33.9 0s-9.4-24.6 0-33.9l55-55-55-55c-9.4-9.4-9.4-24.6 0-33.9s24.6-9.4 33.9 0z"
										/>
									</svg>
								{:else if rawVolume <= 60}
									<svg xmlns="http://www.w3.org/2000/svg" height="2em" viewBox="0 0 448 512">
										<path
											d="M301.1 34.8C312.6 40 320 51.4 320 64V448c0 12.6-7.4 24-18.9 29.2s-25 3.1-34.4-5.3L131.8 352H64c-35.3 0-64-28.7-64-64V224c0-35.3 28.7-64 64-64h67.8L266.7 40.1c9.4-8.4 22.9-10.4 34.4-5.3zM412.6 181.5C434.1 199.1 448 225.9 448 256s-13.9 56.9-35.4 74.5c-10.3 8.4-25.4 6.8-33.8-3.5s-6.8-25.4 3.5-33.8C393.1 284.4 400 271 400 256s-6.9-28.4-17.7-37.3c-10.3-8.4-11.8-23.5-3.5-33.8s23.5-11.8 33.8-3.5z"
										/>
									</svg>
								{:else}
									<svg xmlns="http://www.w3.org/2000/svg" height="2em" viewBox="0 0 640 512">
										<path
											d="M533.6 32.5C598.5 85.3 640 165.8 640 256s-41.5 170.8-106.4 223.5c-10.3 8.4-25.4 6.8-33.8-3.5s-6.8-25.4 3.5-33.8C557.5 398.2 592 331.2 592 256s-34.5-142.2-88.7-186.3c-10.3-8.4-11.8-23.5-3.5-33.8s23.5-11.8 33.8-3.5zM473.1 107c43.2 35.2 70.9 88.9 70.9 149s-27.7 113.8-70.9 149c-10.3 8.4-25.4 6.8-33.8-3.5s-6.8-25.4 3.5-33.8C475.3 341.3 496 301.1 496 256s-20.7-85.3-53.2-111.8c-10.3-8.4-11.8-23.5-3.5-33.8s23.5-11.8 33.8-3.5zm-60.5 74.5C434.1 199.1 448 225.9 448 256s-13.9 56.9-35.4 74.5c-10.3 8.4-25.4 6.8-33.8-3.5s-6.8-25.4 3.5-33.8C393.1 284.4 400 271 400 256s-6.9-28.4-17.7-37.3c-10.3-8.4-11.8-23.5-3.5-33.8s23.5-11.8 33.8-3.5zM301.1 34.8C312.6 40 320 51.4 320 64V448c0 12.6-7.4 24-18.9 29.2s-25 3.1-34.4-5.3L131.8 352H64c-35.3 0-64-28.7-64-64V224c0-35.3 28.7-64 64-64h67.8L266.7 40.1c9.4-8.4 22.9-10.4 34.4-5.3z"
										/>
									</svg>
								{/if}
							</button>

							<div class="radio-control-volume-slider">
								<input
									title="Volume"
									type="range"
									class="custom-range"
									min="0"
									max="100"
									step="1"
									bind:value={rawVolume}
								/>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>

<style>
	.page {
		color: #e0e0e0;
		height: 100vh;
		display: flex;
		align-items: center;
		justify-content: center;
	}

	.card {
		border-radius: 4px;
		box-shadow: 0 0 4px 0 rgba(0, 0, 0, 0.14), 0 3px 4px 0 rgba(0, 0, 0, 0.12),
			0 1px 5px 0 rgba(0, 0, 0, 0.2);
		display: flex;
		flex-direction: column;
		min-width: 0;
		position: relative;
		word-wrap: break-word;
		background-color: #242731;
		width: 500px;
	}

	.card-body {
		flex: 1 1 auto;
		padding: 1rem 1rem;
		border-top-left-radius: 4px;
		border-top-right-radius: 4px;
		position: relative;
	}

	.card-title {
		font-size: 1.225rem;
		letter-spacing: 0;
		line-height: 1.333334;
		margin-bottom: 1rem;
		color: inherit;
		font-weight: 700;
	}

	.now-playing-details {
		display: flex;
		align-items: center;
	}

	hr {
		height: 0;
		overflow: visible;
		border: 0;
		border-top: 1px solid #424242;
		margin-top: 1rem;
		margin-bottom: 0.5rem;
	}

	.radio-controls {
		display: flex;
		flex-direction: row;
		justify-content: space-between;
		align-items: center;
	}

	.play {
		background-color: transparent;
		cursor: pointer;
	}

	.play svg {
		fill: #2196f3;
	}

	.play:hover svg {
		fill: #42a5f5;
	}

	.volume {
		width: 36px;
		height: 36px;
		margin-right: 1rem;
	}

	.volume svg {
		width: 36px;
		height: 36px;
		fill: #757575;
	}

	.volume:hover svg {
		fill: #424242;
	}

	.custom-range {
		margin: 0;
		overflow: visible;
		appearance: none;
		background-color: #424242;
		padding-left: 0;
		width: 100%;
		height: 5px;
		display: flex;
		align-items: center;
	}

	.radio-control-volume-slider {
		flex: 1 1 auto;
	}

	.now-playing-art {
		padding-right: 0.5rem;
	}

	.album-art {
		color: #2196f3;
		box-sizing: inherit;
		border-style: none;
		vertical-align: middle;
		width: 75px;
		height: auto;
		border-radius: 5px;
	}

	.w-1\/3 {
		width: 50%;
	}

	.flex {
		display: flex;
	}

	.align-center {
		align-items: center;
	}
</style>
