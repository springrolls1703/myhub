package edu.harvard.cs50.pokedex;

import androidx.annotation.Nullable;
import androidx.appcompat.app.ActionBarDrawerToggle;
import androidx.appcompat.app.AppCompatActivity;

import android.app.DownloadManager;
import android.content.Context;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.strictmode.WebViewMethodCalledOnWrongThreadViolation;
import android.preference.PreferenceManager;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.ToggleButton;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.JsonObjectRequest;
import com.android.volley.toolbox.JsonRequest;
import com.android.volley.toolbox.Volley;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.w3c.dom.Text;

import java.io.IOException;
import java.net.URL;
import java.nio.file.FileAlreadyExistsException;
import java.util.Iterator;

import static android.app.PendingIntent.getActivity;

public class PokemonActivity extends AppCompatActivity {
    private TextView nameTextView;
    private TextView numberTextView;
    private TextView type1TextView;
    private TextView type2TextView;
    private String url;
    private RequestQueue requestQueue;
    private Button Catch;
    private ImageView pokemonView;
    private TextView pokemonDescription;



    private SharedPreferences sharedPref;
    private SharedPreferences.Editor editor;
    public String namePokemon;
    public String textButton;
    private String imageURL;
    private String DescriptionURL;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_pokemon);

        requestQueue = Volley.newRequestQueue(getApplicationContext());
        url = getIntent().getStringExtra("url");
        nameTextView = findViewById(R.id.pokemon_name);
        numberTextView = findViewById(R.id.pokemon_number);
        type1TextView = findViewById(R.id.pokemon_type1);
        type2TextView = findViewById(R.id.pokemon_type2);
        pokemonView = findViewById(R.id.pokemon_picture);
        Catch = findViewById(R.id.button);
        pokemonDescription = findViewById(R.id.pokemon_description);
        sharedPref = PreferenceManager.getDefaultSharedPreferences(this);
        editor = sharedPref.edit();
        load();
    }


    public void load() {
        type1TextView.setText("");
        type2TextView.setText("");

        JsonObjectRequest request = new JsonObjectRequest(Request.Method.GET, url, null, new Response.Listener<JSONObject>() {
            @Override
            public void onResponse(JSONObject response) {
                try {
                    nameTextView.setText(response.getString("name").substring(0, 1).toUpperCase() + response.getString("name").substring(1));
                    numberTextView.setText("Pokemon ID: " + String.format("#%03d", response.getInt("id")));
                    loadButton(nameTextView);
                    JSONArray typeEntries = response.getJSONArray("types");
                    for (int i = 0; i < typeEntries.length(); i++) {
                        JSONObject typeEntry = typeEntries.getJSONObject(i);
                        int slot = typeEntry.getInt("slot");
                        String type = typeEntry.getJSONObject("type").getString("name");

                        if (slot == 1) {
                            type1TextView.setText("Primary Type: "+ type);
                        }
                        else if (slot == 2) {
                            type2TextView.setText("Secondary Type: "+ type);
                        }
                    }
                    JSONObject spritesEntries = response.getJSONObject("sprites");
                    imageURL = spritesEntries.getString("front_default");
                    loadImage(imageURL);
                    String PokemonID = String.valueOf(response.getInt("id"));
                    loadDescription(PokemonID);
                } catch (JSONException e) {
                    Log.e("cs50", "Pokemon json error", e);
                }
            }
        }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
                Log.e("cs50", "Pokemon details error", error);
            }
        });
        requestQueue.add(request);
    }
    private class DownloadSpriteTask extends AsyncTask<String,Void, Bitmap> {
        @Override
        protected Bitmap doInBackground(String... strings) {
            try {
                URL url = new URL(strings[0]);
                return BitmapFactory.decodeStream(url.openStream());
            }
            catch (IOException e) {
                Log.e("cs50", "Download sprite error", e);
                return null;
            }
        }
        @Override
        protected void onPostExecute(Bitmap bitmap) {
            pokemonView.setImageBitmap(bitmap);
        }
    }
    public void loadImage(String string) {
        new DownloadSpriteTask().execute(string);
    }

    public void loadDescription(String string) {
        DescriptionURL = "https://pokeapi.co/api/v2/pokemon-species/".concat(string);
        JsonObjectRequest request = new  JsonObjectRequest(Request.Method.GET, DescriptionURL, null, new Response.Listener<JSONObject>() {
            @Override
            public void onResponse(JSONObject response) {
                try {
                    JSONArray typeEntriesText = response.getJSONArray("flavor_text_entries");
                    for (int t = 0; t <= typeEntriesText.length(); t++) {
                        JSONObject typeEntry = typeEntriesText.getJSONObject(t);
                        String Description = "";
                        Description = typeEntry.getString("flavor_text");
                        if (Description != "") {
                            pokemonDescription.setText(Description.replace("\n", " "));
                            break;
                        }
                    }
                } catch (JSONException e) {
                    Log.e("cs50", "load description error");
                }
            }
        }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
                Log.e("cs50","load Description error");
            }
        });
        requestQueue.add(request);
    }
    public void toggleCatch(View view) {
        if ((Catch).isPressed()) {
            if(Catch.getText().toString() == "Catch") {
                textButton = "Release";
                Catch.setText(textButton);
                saveData(nameTextView);
            }
            else {
                Catch.setText("Catch");
                clearData(nameTextView);
            }
        }
    }
    public void loadButton(TextView textView) {
        namePokemon = textView.getText().toString();
        if(sharedPref.getBoolean(namePokemon,false) == false) {
            Catch.setText("Catch");
        }
        else {
            Catch.setText("Release");
        }
    }
    public void saveData(TextView textView) {
        namePokemon = textView.getText().toString().toLowerCase();
        editor.putBoolean(namePokemon,true).commit();
        editor.apply();
        Toast.makeText(this,namePokemon+" is caught", Toast.LENGTH_SHORT).show();
    }
    public void clearData(TextView textView) {
        namePokemon = textView.getText().toString().toLowerCase();
        editor.remove(namePokemon);
        editor.apply();
    }
}
