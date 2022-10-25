//Registration
Bundle bundle = new Bundle();
bundle.putString(FirebaseAnalytics.Param.method, {{method_name}});
mFirebaseAnalytics.logEvent(FirebaseAnalytics.Event.sign_up, bundle);

//ViewContent
Bundle bundle = new Bundle();
bundle.putString(FirebaseAnalytics.Param.ITEM_ID, {{movies_id}});
bundle.putString(FirebaseAnalytics.Param.CONTENT_TYPE, "movies_pageview");
mFirebaseAnalytics.logEvent(FirebaseAnalytics.Event.SELECT_CONTENT, bundle);

//checkout
Bundle checkout = new Bundle();
checkout.putString("category", {{SVOD/TVOD}});
mFirebaseAnalytics.logEvent("check_out", checkout);

//play
Bundle play = new Bundle();
play.putString("movie", {{movie_name}});
mFirebaseAnalytics.logEvent("play", play);

