package xyz.luan.audioplayers;

import android.media.AudioAttributes;
import android.media.AudioManager;
import android.media.SoundPool;
import android.os.Build;
import android.os.PowerManager;
import android.content.Context;
import android.util.Log;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.net.URL;
import java.util.Map;
import java.util.List;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Collections;

import static java.io.File.createTempFile;

public class WrappedSoundPool extends Player {

    private static SoundPool soundPool = createSoundPool();
    static {
        soundPool.setOnLoadCompleteListener(new SoundPool.OnLoadCompleteListener() {
            public void onLoadComplete(SoundPool soundPool, int sampleId, int status) {
                Log.d("WSP", "Loaded " + sampleId);
                WrappedSoundPool loadingPlayer = soundIdToPlayer.get(sampleId);
                if (loadingPlayer != null) {
                    soundIdToPlayer.remove(loadingPlayer.soundId);
                    // Now mark all players using this sound as not loading and start them if necessary
                    synchronized (urlToPlayers) {
                        List<WrappedSoundPool> urlPlayers = urlToPlayers.get(loadingPlayer.url);
                        for (WrappedSoundPool player : urlPlayers) {
                            Log.d("WSP", "Marking " + player + " as loaded");
                            player.loading = false;
                            if (player.playing) {
                                Log.d("WSP", "Delayed start of " + player);
                                player.start();
                            }
                        }
                    }
                }
            }
        });
    }

    /** For the onLoadComplete listener, track which sound id is associated with which player. An entry only exists until
     * it has been loaded.
     */
    private static Map<Integer, WrappedSoundPool> soundIdToPlayer = Collections.synchronizedMap(new HashMap<Integer, WrappedSoundPool>());
    /** This is to keep track of the players which share the same sound id, referenced by url. When a player release()s, it
     * is removed from the associated player list. The last player to be removed actually unloads() the sound id and then
     * the url is removed from this map.
     */
    private static Map<String, List<WrappedSoundPool>> urlToPlayers = Collections.synchronizedMap(new HashMap<String, List<WrappedSoundPool>>());


    private final AudioplayersPlugin ref;

    private final String playerId;

    private String url;

    private float volume = 1.0f;

    private float rate = 1.0f;

    private Integer soundId;

    private Integer streamId;

    private boolean playing = false;

    private boolean paused = false;

    private boolean looping = false;

    private boolean loading = false;

    private String playingRoute = "speakers";

    WrappedSoundPool(AudioplayersPlugin ref, String playerId) {
        this.ref = ref;
        this.playerId = playerId;
    }

    @Override
    String getPlayerId() {
        return playerId;
    }

    @Override
    void play(Context context) {
        if (!this.loading) {
            start();
        }
        this.playing = true;
    }

    @Override
    void stop() {
        if (this.playing) {
            soundPool.stop(this.streamId);
            this.playing = false;
        }
        this.paused = false;
    }

    @Override
    void release() {
        this.stop();
        if (this.soundId != null && this.url != null) {
            synchronized (this.urlToPlayers) {
                List<WrappedSoundPool> playersForSoundId = this.urlToPlayers.get(this.url);
                if (playersForSoundId != null) {
                    if (playersForSoundId.size() == 1 && playersForSoundId.get(0) == this) {
                        this.urlToPlayers.remove(this.url);
                        soundPool.unload(this.soundId);
                        soundIdToPlayer.remove(this.soundId);
                        this.soundId = null;
                        Log.d("WSP", "Unloaded soundId " + this.soundId);
                    } else {
                        // This is not the last player using the soundId, just remove it from the list.
                        playersForSoundId.remove(this);
                    }
                }
            }
        }
    }

    @Override
    void pause() {
        if (this.playing) {
            soundPool.pause(this.streamId);
            this.playing = false;
            this.paused = true;
        }
    }

    @Override
    void setUrl(final String url, final boolean isLocal, Context context) {
        if (this.url != null && this.url.equals(url)) {
            return;
        }

        if (this.soundId != null) {
            release();
        }

        synchronized (urlToPlayers) {
            this.url = url;
            List<WrappedSoundPool> urlPlayers = urlToPlayers.get(url);
            if (urlPlayers != null) {
                // Sound has already been loaded - reuse the soundId.
                WrappedSoundPool originalPlayer = urlPlayers.get(0);
                this.soundId = originalPlayer.soundId;
                this.loading = originalPlayer.loading;
                urlPlayers.add(this);
                Log.d("WSP", "Reusing soundId" + this.soundId + " for " + url + " is loading=" + this.loading + " " + this);
                return;
            }

            // First one for this URL - load it.
            this.loading = true;

            long start = System.currentTimeMillis();
            this.soundId = soundPool.load(getAudioPath(url, isLocal), 1);
            Log.d("WSP", "time to call load() for " + url + ": " + (System.currentTimeMillis() - start) + " player=" + this);
            soundIdToPlayer.put(this.soundId, this);
            urlPlayers = new ArrayList<>();
            urlPlayers.add(this);
            urlToPlayers.put(url, urlPlayers);
        }
    }

    @Override
    void setVolume(double volume) {
        this.volume = (float) volume;
        if (this.playing) {
            soundPool.setVolume(this.streamId, this.volume, this.volume);
        }
    }

    @Override
    int setRate(double rate) {
        this.rate = (float) rate;
        if (this.streamId != null) {
            soundPool.setRate(this.streamId, this.rate);
            return 1;
        }
        return 0;
    }

    @Override
    void configAttributes(boolean respectSilence, boolean setWakeMode, Context context) {
    }

    @Override
    void setReleaseMode(ReleaseMode releaseMode) {
        this.looping = releaseMode == ReleaseMode.LOOP;
        if (this.playing) {
            soundPool.setLoop(streamId, this.looping ? -1 : 0);
        }
    }

    @Override
    int getDuration() {
        throw unsupportedOperation("getDuration");
    }

    @Override
    int getCurrentPosition() {
        throw unsupportedOperation("getCurrentPosition");
    }

    @Override
    boolean isActuallyPlaying() {
        return false;
    }

    @Override
    void setPlayingRoute(String playingRoute, Context context) {
        throw unsupportedOperation("setPlayingRoute");
    }

    @Override
    void seek(int position) {
        throw unsupportedOperation("seek");
    }

    private static SoundPool createSoundPool() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            AudioAttributes attrs = new AudioAttributes
                    .Builder().setLegacyStreamType(AudioManager.USE_DEFAULT_STREAM_TYPE)
                    .setUsage(AudioAttributes.USAGE_GAME)
                    .build();
            return new SoundPool.Builder()
                    .setAudioAttributes(attrs)
                    .setMaxStreams(100)
                    .build();
        }
        return unsafeBuildLegacySoundPool();
    }

    @SuppressWarnings("deprecation")
    private static SoundPool unsafeBuildLegacySoundPool() {
        return new SoundPool(1, AudioManager.STREAM_MUSIC, 1);
    }

    private void start() {
        setRate(this.rate);
        if (this.paused) {
            soundPool.resume(this.streamId);
            this.paused = false;
        } else {
            this.streamId = soundPool.play(
                    soundId,
                    this.volume,
                    this.volume,
                    0,
                    this.looping ? -1 : 0,
                    1.0f);
        }
    }

    private String getAudioPath(String url, boolean isLocal) {
        if (isLocal) {
            return url;
        }
        return loadTempFileFromNetwork(url).getAbsolutePath();
    }

    private File loadTempFileFromNetwork(String url) {
        FileOutputStream fileOutputStream = null;
        try {
            byte[] bytes = downloadUrl(URI.create(url).toURL());
            File tempFile = createTempFile("sound", "");
            fileOutputStream = new FileOutputStream(tempFile);
            fileOutputStream.write(bytes);
            tempFile.deleteOnExit();
            return tempFile;
        } catch (IOException e) {
            throw new RuntimeException(e);
        } finally {
            try {
                if (fileOutputStream != null) {
                    fileOutputStream.close();
                }
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }
    }

    private byte[] downloadUrl(URL url) {
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();

        InputStream stream = null;
        try {
            byte[] chunk = new byte[4096];
            int bytesRead;
            stream = url.openStream();

            while ((bytesRead = stream.read(chunk)) > 0) {
                outputStream.write(chunk, 0, bytesRead);
            }

        } catch (IOException e) {
            throw new RuntimeException(e);
        } finally {
            try {
                stream.close();
            } catch (IOException e) {
                throw new RuntimeException(e);
            }
        }

        return outputStream.toByteArray();
    }

    private UnsupportedOperationException unsupportedOperation(String message) {
        return new UnsupportedOperationException("LOW_LATENCY mode does not support: " + message);
    }

}
