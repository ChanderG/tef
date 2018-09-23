import termbox;
import std.range;
import std.algorithm;
import std.conv;

import std.file;

// add text at the top leaving a border of 1 
void drawText(const string[] text) {
	auto trunc = text.take(height-2).map!(a => a.take(width-2)).array.to!(string[]);
	foreach (j, line; trunc) foreach (i, t; line) setCell(1+cast(int)i, 1+cast(int)j, t, Color.white, Color.basic);
	flush;
}

void changeCurrLine(string[] text, ref int currline, int diff){
	if ((currline+diff < 0) || (currline+diff >= text.length)) return;
	foreach(i, t; text[currline]) setCell(1+cast(int)i, 1+currline, t, Color.white, Color.basic);
	currline += diff;
	foreach(i, t; text[currline]) setCell(1+cast(int)i, 1+currline, t, Color.blue, Color.white);
	flush;
}

void main()
{
	init;

	auto files = dirEntries("", SpanMode.shallow).array.to!(string[]);

	drawText(files);
	int currline = 0;
	changeCurrLine(files, currline, 0);

	Event e;
	do {
		pollEvent(&e);
		switch(e.key){
			case Key.arrowUp: changeCurrLine(files, currline, -1); break;
			case Key.arrowDown: changeCurrLine(files, currline, 1); break;
			default: break;
		}
	} while (e.key != Key.esc);

	shutdown;
}
