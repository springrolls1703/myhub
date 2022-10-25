package edu.harvard.cs50.myapplication;

import androidx.appcompat.app.AppCompatActivity;

import android.nfc.tech.NfcA;
import android.os.Bundle;
import android.util.Log;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.NavigableMap;
import java.util.Random;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        List<Track> tracks = new ArrayList<>();
        tracks.add(new Track("Mobile", "Tommy")); // just input the value it will automatically remind the type
        tracks.add(new Track("Web", "Brian"));
        tracks.add(new Track("Games", "Colton"));
        List<String> students = Arrays.asList("Harry", "Ron", "Hermione");
        Map<String, Track> assignments = new HashMap<>();
        Random random = new Random();
        for (String student: students) {
            int index = random.nextInt(tracks.size());
            assignments.put(student, tracks.get(index));
        }
        for (Map.Entry<String, Track> entry : assignments.entrySet()) {
            Log.d("cs50", entry.getKey() + " got " + entry.getValue().name + " with " +
                    entry.getValue().instructor);
        }
    }
}

