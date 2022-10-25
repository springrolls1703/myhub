package com.example.calendar;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresPermission;
import androidx.appcompat.app.AppCompatActivity;

import android.content.ContentValues;
import android.content.SharedPreferences;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.graphics.Color;
import android.os.Bundle;
import android.provider.CalendarContract;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.Toast;

import com.applandeo.materialcalendarview.CalendarView;
import com.applandeo.materialcalendarview.EventDay;
import com.applandeo.materialcalendarview.listeners.OnDayClickListener;
import com.applandeo.materialcalendarview.listeners.OnSelectDateListener;
import com.google.android.material.bottomappbar.BottomAppBar;
import com.google.android.material.bottomsheet.BottomSheetBehavior;
import com.google.gson.Gson;

import java.sql.RowId;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.TimeZone;

import static android.text.format.DateFormat.format;
import static java.text.DateFormat.*;
import static java.util.Calendar.*;


public class MainActivity extends AppCompatActivity {
    private MySQLiteDBHandler dbHandler;
    private LinearLayout bottomSheet;
    private BottomSheetBehavior bottomSheetBehavior;
    private LinearLayout mheaderLayout;
    private ImageView mheaderImage;
    public com.applandeo.materialcalendarview.CalendarView calendarView;
    EditText editText;
    EditText editText2;
    Button saveButton;
    Button deleteButton;
    private String selectedDate;
    private SQLiteDatabase sqLiteDatabase;
    List<EventDay> events;
    private Calendar clickedDayCalendar;
    private SharedPreferences sharedPref;
    private SharedPreferences.Editor editor;
    private Map<String,?> keys;
    int mYear;
    int mMonth;
    int mDate;
    long mtoday;
    String Today;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        bottomSheet = findViewById(R.id.bottom_sheet);
        bottomSheetBehavior = BottomSheetBehavior.from(bottomSheet);
        mheaderLayout = findViewById(R.id.header_layout);
        mheaderImage = findViewById(R.id.header_image);
        mheaderImage.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(bottomSheetBehavior.getState() != BottomSheetBehavior.STATE_EXPANDED){
                    bottomSheetBehavior.setState(BottomSheetBehavior.STATE_EXPANDED);
                } else {
                    bottomSheetBehavior.setState(BottomSheetBehavior.STATE_COLLAPSED);
                }
            }
        });
        events = new ArrayList<>();
        sharedPref = getPreferences(MODE_PRIVATE);
        editor = sharedPref.edit();
        keys = sharedPref.getAll();
        loadEvents();
        editText = findViewById(R.id.editText);
        calendarView = findViewById(R.id.calendarView);
        calendarView.setEvents(events);
        editText2 = findViewById(R.id.editText2);
        saveButton = findViewById(R.id.button);
        deleteButton = findViewById(R.id.button2);
        try {
            dbHandler = new MySQLiteDBHandler(this, "CalendarDatabase",null,1);
            sqLiteDatabase = dbHandler.getWritableDatabase();
            sqLiteDatabase.execSQL("CREATE TABLE EventCalendar (Date TEXT PRIMARY KEY, Event TEXT, EventDescription TEXT)");
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        Calendar calendar = Calendar.getInstance(TimeZone.getTimeZone("+7"));
        long today = calendar.getTimeInMillis();
        Today = format("yyyyMMdd", new Date(today)).toString();
        selectedDate = Today;
        LoadToday();
        calendarView.setOnDayClickListener(new OnDayClickListener() {
            @Override
            public void onDayClick(EventDay eventDay) {
                if(eventDay != null) {
                    clickedDayCalendar = eventDay.getCalendar();
                    long date = clickedDayCalendar.getTimeInMillis();
                    selectedDate = format("yyyyMMdd", new Date(date)).toString();
                    ReadDatabase(selectedDate);
                }
            }
        });
    }
    public void InsertDatabase(View view) {
        ContentValues contentValues = new ContentValues();
        contentValues.put("Date", selectedDate);
        contentValues.put("Event", editText.getText().toString());
        contentValues.put("EventDescription", editText2.getText().toString());
        sqLiteDatabase.delete("EventCalendar","Date = " + selectedDate,null);
        sqLiteDatabase.replace("EventCalendar", null, contentValues);
        Calendar calendar = calendarView.getFirstSelectedDate();
        Gson gson = new Gson();
        String json = gson.toJson(calendar);
        editor.putString(selectedDate,json).commit();
        editor.apply();
        events.add(new EventDay(calendar,R.mipmap.note3_foreground));
        calendarView.setEvents(events);
    }

    public void DeleteDatabase(View view) {
        sqLiteDatabase.delete("EventCalendar","Date = " + selectedDate,null);
        String Query = "Select Event, EventDescription from EventCalendar where Date = " + selectedDate;
        editText.setText("");
        editText2.setText("");
        Gson gson = new Gson();
        Calendar calendar = calendarView.getFirstSelectedDate();
        events = new ArrayList<>();
        editor.remove(selectedDate).commit();
        editor.apply();
        keys = sharedPref.getAll();
        loadEvents();
        events.remove(new EventDay(calendar,R.mipmap.note3_foreground));
        calendarView.setEvents(events);
    }
    public void ReadDatabase(String Date) {
        String Query = "Select Event, EventDescription from EventCalendar where Date = " + Date;
        try {
            Cursor cursor = sqLiteDatabase.rawQuery(Query,null);
            cursor.moveToFirst();
            editText.setText(cursor.getString(0));
            editText2.setText(cursor.getString(1));
            cursor.close();
        } catch (Exception e) {
            e.printStackTrace();
            editText.setText("");
            editText2.setText("");
        }
    }
    public void LoadToday() {
        try {
            String Query = "Select Event, EventDescription from EventCalendar where Date = " + Today;
            Cursor cursor = sqLiteDatabase.rawQuery(Query, null);
            if (cursor != null && cursor.getCount() != 0) {
                cursor.moveToFirst();
                editText.setText(cursor.getString(0));
                editText2.setText(cursor.getString(1));
            }
            cursor.close();
        } catch (Exception e) {
            editText.setText("");
            editText2.setText("");
            return;
        }
    }
    public void loadEvents() {
        for(Map.Entry<String,?> entry : keys.entrySet()){
            String json = entry.getValue().toString();
            Gson gson = new Gson();
            Calendar obj = gson.fromJson(json, Calendar.class);
            events.add(new EventDay(obj, R.mipmap.note3_foreground));
        }
    }
}
