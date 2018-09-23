import termbox;
import std.range;
import std.algorithm;
import std.conv;

import std.file;

ushort getColor(string filename){
	if (filename.isDir) return Color.blue;
	else if (filename.isFile) return Color.white;
	else return Color.yellow;
}

// add text at the top leaving a border of 1 
void drawText(const string[] text) {
	auto trunc = text.take(height-2).map!(a => a.take(width-2)).array.to!(string[]);
	foreach (j, line; trunc) {
		auto color = line.getColor;
		foreach (i, t; line) setCell(1+cast(int)i, 1+cast(int)j, t, color, Color.basic);
	}
	flush;
}

void changeCurrLine(string[] text, ref int currline, int diff){
	if ((currline+diff < 0) || (currline+diff >= text.length)) return;
	// reset current line
	foreach(i, t; text[currline]) setCell(1+cast(int)i, 1+currline, t, text[currline].getColor, Color.basic);
	currline += diff;
	// highlight new line
	foreach(i, t; text[currline]) setCell(1+cast(int)i, 1+currline, t, Color.black, text[currline].getColor);
	flush;
}

void changeDir(ref string[] files, const string dir, ref int currline){
	if (!dir.isDir) return;

	clear;
	dir.chdir;
	files = dirEntries("", SpanMode.shallow).array.to!(string[]);
	files.drawText;
	currline = 0;
	changeCurrLine(files, currline, 0);
}

void main()
{
	init;

	string[] files;
	int currline = 0;

	changeDir(files, ".", currline);

	Event e;
	do {
		pollEvent(&e);
		switch(e.key){
			case Key.arrowUp: changeCurrLine(files, currline, -1); break;
			case Key.arrowDown: changeCurrLine(files, currline, 1); break;
			case Key.arrowLeft: changeDir(files, "..", currline); break;
			case Key.arrowRight: changeDir(files, files[currline], currline); break;
			default: break;
		}
	} while (e.key != Key.esc);

	shutdown;
}
