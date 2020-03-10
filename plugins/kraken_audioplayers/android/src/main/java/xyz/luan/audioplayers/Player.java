package xyz.luan.audioplayers;

import android.content.Context;
abstract class Player {

    protected static boolean objectEquals(Object o1, Object o2) {
        return o1 == null && o2 == null || o1 != null && o1.equals(o2);
    }

    abstract String getPlayerId();

    abstract void play(Context context);

    abstract void stop();

    abstract void release();

    abstract void pause();

    abstract void setUrl(String url, boolean isLocal, Context context);

    abstract void setVolume(double volume);

    abstract int setRate(double rate);

    abstract void configAttributes(boolean respectSilence, boolean stayAwake, Context context);

    abstract void setReleaseMode(ReleaseMode releaseMode);

    abstract int getDuration();

    abstract int getCurrentPosition();

    abstract boolean isActuallyPlaying();

    abstract void setPlayingRoute(String playingRoute, Context context);

    /**
     * Seek operations cannot be called until after the player is ready.
     */
    abstract void seek(int position);
}
