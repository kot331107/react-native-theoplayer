package com.theoplayer.ads;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.theoplayer.SourceHelper;
import com.theoplayer.android.api.player.Player;
import com.theoplayer.util.ViewResolver;

public class AdsModule extends ReactContextBaseJavaModule {
  private final SourceHelper sourceHelper = new SourceHelper();
  private final ViewResolver viewResolver;

  public AdsModule(ReactApplicationContext context) {
    super(context);
    viewResolver = new ViewResolver(context);
  }

  @NonNull
  @Override
  public String getName() {
    return "AdsModule";
  }

  // Add an ad break request.
  @ReactMethod
  public void schedule(Integer tag, ReadableMap ad) {
    viewResolver.resolveViewByTag(tag, view -> {
      Player player = view != null ? view.getPlayer() : null;
      if (player != null) {
        player.getAds().schedule(sourceHelper.parseAdFromJS(ad));
      }
    });
  }

  // The currently playing ad break.
  @ReactMethod
  public void currentAdBreak(Integer tag, Callback successCallBack) {
    viewResolver.resolveViewByTag(tag, view -> {
      Player player = view != null ? view.getPlayer() : null;
      if (player == null) {
        successCallBack.invoke(Arguments.createMap());
      } else {
        successCallBack.invoke(AdInfo.fromAdbreak(player.getAds().getCurrentAdBreak()));
      }
    });
  }

  // List of ad breaks which still need to be played.
  @ReactMethod
  public void scheduledAdBreaks(Integer tag, Callback successCallBack) {
    viewResolver.resolveViewByTag(tag, view -> {
      Player player = view != null ? view.getPlayer() : null;
      if (player == null) {
        successCallBack.invoke(Arguments.createMap());
      } else {
        // TODO
        successCallBack.invoke(Arguments.createMap());
      }
    });
  }

  // Whether a linear ad is currently playing.
  @ReactMethod
  public void playing(Integer tag, Callback successCallBack) {
    viewResolver.resolveViewByTag(tag, view -> {
      Player player = view != null ? view.getPlayer() : null;
      if (player == null) {
        successCallBack.invoke(false);
      } else {
        successCallBack.invoke(player.getAds().isPlaying());
      }
    });
  }

  // Skip the current linear ad.
  // NOTE: This will have no effect when the current linear ad is (not yet) skippable.
  @ReactMethod
  public void skip(Integer tag) {
    viewResolver.resolveViewByTag(tag, view -> {
      Player player = view != null ? view.getPlayer() : null;
      if (player != null) {
        player.getAds().skip();
      }
    });
  }
}
