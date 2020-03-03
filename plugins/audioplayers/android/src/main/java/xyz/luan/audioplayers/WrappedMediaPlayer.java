package xyz.luan.audioplayers;

import android.media.AudioAttributes;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.os.Build;
import android.os.PowerManager;
import android.content.Context;

import java.io.IOException;

public class WrappedMediaPlayer extends Player implements MediaPlayer.OnPreparedListener, MediaPlayer.OnCompletionListener, MediaPlayer.OnSeekCompleteListener {

    private String playerId;

    private String url;
    private double volume = 1.0;
    private float rate = 1.0f;
    private boolean respectSilence;
    private boolean stayAwake;
    private ReleaseMode releaseMode = ReleaseMode.RELEASE;
    private String playingRoute = "speakers";

    private boolean released = true;
    private boolean prepared = false;
    private boolean playing = false;

    private int shouldSeekTo = -1;

    private MediaPlayer player;
    private AudioplayersPlugin ref;

    WrappedMediaPlayer(AudioplayersPlugin ref, String playerId) {
        this.ref = ref;
        this.playerId = playerId;
    }

    /**
     * Setter methods
     */

    @Override
    void setUrl(String url, boolean isLocal, Context context) {
        if (!objectEquals(this.url, url)) {
            this.url = url;
            if (this.released) {
                this.player = createPlayer(context);
                this.released = false;
            } else if (this.prepared) {
                this.player.reset();
                this.prepared = false;
            }

            this.setSource(url);
            this.player.setVolume((float) volume, (float) volume);
            this.player.setLooping(this.releaseMode == ReleaseMode.LOOP);
            this.player.prepareAsync();
        }
    }

    @Override
    void setVolume(double volume) {
        if (this.volume != volume) {
            this.volume = volume;
            if (!this.released) {
                this.player.setVolume((float) volume, (float) volume);
            }
        }
    }

    @Override
    void setPlayingRoute(String playingRoute, Context context) {
        if (!objectEquals(this.playingRoute, playingRoute)) {
            boolean wasPlaying = this.playing;
            if (wasPlaying) {
                this.pause();
            }

            this.playingRoute = playingRoute;

            int position = 0;
            if (player != null) {
                position = player.getCurrentPosition();
            }

            this.released = false;
            this.player = createPlayer(context);
            this.setSource(url);
            try {
                this.player.prepare();
            } catch (IOException ex) {
                throw new RuntimeException("Unable to access resource", ex);
            }

            this.seek(position);
            if (wasPlaying) {
                this.playing = true;
                this.player.start();
            }
        }
    }

    @Override
    int setRate(double rate) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            throw new UnsupportedOperationException("The method 'setRate' is available only on Android SDK version " + Build.VERSION_CODES.M + " or higher!");
        }
        if (this.player != null) {
            this.rate = (float) rate;
            this.player.setPlaybackParams(this.player.getPlaybackParams().setSpeed(this.rate));
            return 1;
        }
        return 0;
    }

    @Override
    void configAttributes(boolean respectSilence, boolean stayAwake, Context context) {
        if (this.respectSilence != respectSilence) {
            this.respectSilence = respectSilence;
            if (!this.released) {
                setAttributes(player, context);
            }
        }
        if (this.stayAwake != stayAwake) {
            this.stayAwake = stayAwake;
            if (!this.released && this.stayAwake) {
                this.player.setWakeMode(context, PowerManager.PARTIAL_WAKE_LOCK);
            }
        }
    }

    @Override
    void setReleaseMode(ReleaseMode releaseMode) {
        if (this.releaseMode != releaseMode) {
            this.releaseMode = releaseMode;
            if (!this.released) {
                this.player.setLooping(releaseMode == ReleaseMode.LOOP);
            }
        }
    }

    /**
     * Getter methods
     */

    @Override
    int getDuration() {
        return this.player.getDuration();
    }

    @Override
    int getCurrentPosition() {
        return this.player.getCurrentPosition();
    }

    @Override
    String getPlayerId() {
        return this.playerId;
    }

    @Override
    boolean isActuallyPlaying() {
        return this.playing && this.prepared;
    }

    /**
     * Playback handling methods
     */

    @Override
    void play(Context context) {
        if (!this.playing) {
            this.playing = true;
            if (this.released) {
                this.released = false;
                this.player = createPlayer(context);
                this.setSource(url);
                this.player.prepareAsync();
            } else if (this.prepared) {
                this.player.start();
                this.ref.handleIsPlaying(this);
            }
        }
    }

    @Override
    void stop() {
        if (this.released) {
            return;
        }

        if (releaseMode != ReleaseMode.RELEASE) {
            if (this.playing) {
                this.playing = false;
                this.player.pause();
                this.player.seekTo(0);
            }
        } else {
            this.release();
        }
    }

    @Override
    void release() {
        if (this.released) {
            return;
        }

        if (this.playing) {
            this.player.stop();
        }
        this.player.reset();
        this.player.release();
        this.player = null;

        this.prepared = false;
        this.released = true;
        this.playing = false;
    }

    @Override
    void pause() {
        if (this.playing) {
            this.playing = false;
            this.player.pause();
        }
    }

    // seek operations cannot be called until after
    // the player is ready.
    @Override
    void seek(int position) {
        if (this.prepared)
            this.player.seekTo(position);
        else
            this.shouldSeekTo = position;
    }

    /**
     * MediaPlayer callbacks
     */

    @Override
    public void onPrepared(final MediaPlayer mediaPlayer) {
        this.prepared = true;
        ref.handleDuration(this);
        if (this.playing) {
            this.player.start();
            ref.handleIsPlaying(this);
        }
        if (this.shouldSeekTo >= 0) {
            this.player.seekTo(this.shouldSeekTo);
            this.shouldSeekTo = -1;
        }
    }

    @Override
    public void onCompletion(final MediaPlayer mediaPlayer) {
        if (releaseMode != ReleaseMode.LOOP) {
            this.stop();
        }
        ref.handleCompletion(this);
    }

    @Override
    public void onSeekComplete(final MediaPlayer mediaPlayer) {
        ref.handleSeekComplete(this);
    }

    /**
     * Internal logic. Private methods
     */

    private MediaPlayer createPlayer(Context context) {
        MediaPlayer player = new MediaPlayer();
        player.setOnPreparedListener(this);
        player.setOnCompletionListener(this);
        player.setOnSeekCompleteListener(this);
        setAttributes(player, context);
        player.setVolume((float) volume, (float) volume);
        player.setLooping(this.releaseMode == ReleaseMode.LOOP);
        return player;
    }

    private void setSource(String url) {
        try {
            this.player.setDataSource(url);
        } catch (IOException ex) {
            throw new RuntimeException("Unable to access resource", ex);
        }
    }

    @SuppressWarnings("deprecation")
    private void setAttributes(MediaPlayer player, Context context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            if (objectEquals(this.playingRoute, "speakers")) {
                player.setAudioAttributes(new AudioAttributes.Builder()
                    .setUsage(respectSilence ? AudioAttributes.USAGE_NOTIFICATION_RINGTONE : AudioAttributes.USAGE_MEDIA)
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .build()
                );
            } else {
                // Works with bluetooth headphones
                // automatically switch to earpiece when disconnect bluetooth headphones
                player.setAudioAttributes(new AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_VOICE_COMMUNICATION)
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .build()
                );
                if ( context != null ) {
                    AudioManager mAudioManager = (AudioManager) context.getSystemService(Context.AUDIO_SERVICE);
                    mAudioManager.setSpeakerphoneOn(false);
                }
            }

        } else {
            // This method is deprecated but must be used on older devices
            if (objectEquals(this.playingRoute, "speakers")) {
                player.setAudioStreamType(respectSilence ? AudioManager.STREAM_RING : AudioManager.STREAM_MUSIC);
            } else {
                player.setAudioStreamType(AudioManager.STREAM_VOICE_CALL);
            }
        }
    }

}
