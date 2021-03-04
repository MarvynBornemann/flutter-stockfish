#include <iostream>
#include <sstream>

#include "../Stockfish/src/bitboard.h"
#include "../Stockfish/src/endgame.h"
#include "../Stockfish/src/position.h"
#include "../Stockfish/src/search.h"
#include "../Stockfish/src/thread.h"
#include "../Stockfish/src/tt.h"
#include "../Stockfish/src/uci.h"
#include "../Stockfish/src/syzygy/tbprobe.h"

#include "flutter_stockfish.h"

namespace PSQT {
  void init();
}

std::stringstream buffer;

void stockfish_init(void) {
	UCI::init(Options);
	Tune::init();
	PSQT::init();
	Bitboards::init();
	Position::init();
	Bitbases::init();
	Endgames::init();
	Threads.set(size_t(Options["Threads"]));
	Search::clear();
	Eval::NNUE::init();
	
	//redirect std::cout output-stream to buffer
	std::cout.rdbuf(buffer.rdbuf());
}

char * stockfish_get_output_buffer() {
	//get output buffer
	char * output = strdup(buffer.str().c_str());
	buffer.str(std::string()); //clear buffer
	
	return output;
}

char * stockfish_uci(char *command) {
	char *argv[1] = {command};
	//do uci loop once
	UCI::loop(1,argv);

	//get output buffer
	char * output = strdup(buffer.str().c_str());
	buffer.str(std::string()); //clear buffer

	return output;
}

void stockfish_dispose(void){
	Threads.set(0);
}