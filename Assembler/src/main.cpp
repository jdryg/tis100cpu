#define _CRT_SECURE_NO_WARNINGS // fopen

#include <stdio.h>
#include <vector>
#include "TIS100Instruction.h"
#include "MicroInstruction.h"
#include "GenericParser.h"
#include "Program.h"

#define PARSER_NO_ERROR 0
#define PARSER_ERROR_UNKNOWN_INSTRUCTION 1
#define PARSER_ERROR_MISSING_SRC_OPERAND 2
#define PARSER_ERROR_MISSING_DST_OPERAND 3
#define PARSER_ERROR_MISSING_COMMA       4
#define PARSER_ERROR_INVALID_SRC_OPERAND 5
#define PARSER_ERROR_INVALID_DST_OPERAND 6
#define PARSER_ERROR_MISSING_JMP_TARGET  7

MIDestination TIStoMIDestination(TIS100Destination dst)
{
	switch (dst)
	{
	case TISD_NIL:
		return MID_NIL;
	case TISD_ACC:
		return MID_ACC;
	case TISD_PORT_UP:
		return MID_PORT_UP;
	case TISD_PORT_DOWN:
		return MID_PORT_DOWN;
	case TISD_PORT_LEFT:
		return MID_PORT_LEFT;
	case TISD_PORT_RIGHT:
		return MID_PORT_RIGHT;
	}

	return MID_Unknown;
}

MISource TIStoMISource(TIS100Source src)
{
	switch (src)
	{
	case TISS_NIL:
		return MIS_NIL;
	case TISS_ACC:
		return MIS_ACC;
	case TISS_PORT_UP:
		return MIS_PORT_UP;
	case TISS_PORT_DOWN:
		return MIS_PORT_DOWN;
	case TISS_PORT_LEFT:
		return MIS_PORT_LEFT;
	case TISS_PORT_RIGHT:
		return MIS_PORT_RIGHT;
	}

	return MIS_Unknown;
}

bool ParseTISFile(const char* filename, std::vector<TIS100Instruction*>& instructionList)
{
	FILE* f = fopen(filename, "rb");
	if (!f)
	{
		return false;
	}

	fseek(f, 0, SEEK_END);
	int fileSize = ftell(f);
	fseek(f, 0, SEEK_SET);

	char* buffer = new char[fileSize + 1];
	fread(buffer, sizeof(char), fileSize, f);
	buffer[fileSize] = '\0';

	fclose(f);

	GenericParser parser(buffer);

	// Parse the file...
	int parseError = PARSER_NO_ERROR;
	while (parser.GetNextChar() != '\0')
	{
		parseError = PARSER_NO_ERROR;

		TIS100Instruction* instr = new TIS100Instruction();

		char token[256];
		if (!parser.GetNextToken(token, 256))
		{
			break;
		}

		// Check if this is a label
		if (parser.GetNextChar() == ':')
		{
			instr->SetLabel(token);

			// Skip colon.
			parser.Expecting(':');
		}
		else
		{
			// This must be an instruction mnemonic.
			if (!_stricmp(token, "nop"))
			{
				instr->SetMnemonic(TISM_NOP);
			}
			else if (!_stricmp(token, "mov"))
			{
				char src[32], dst[32];
				if (!parser.GetNextToken(src, 32))
				{
					parseError = PARSER_ERROR_MISSING_SRC_OPERAND;
					break;
				}
				if (!parser.Expecting(','))
				{
					parseError = PARSER_ERROR_MISSING_COMMA;
					break;
				}
				if (!parser.GetNextToken(dst, 32))
				{
					parseError = PARSER_ERROR_MISSING_DST_OPERAND;
					break;
				}

				instr->SetMnemonic(TISM_MOV);
				if (!instr->SetDestination(dst))
				{
					parseError = PARSER_ERROR_INVALID_DST_OPERAND;
					break;
				}

				if (!instr->SetSource(src))
				{
					parseError = PARSER_ERROR_INVALID_SRC_OPERAND;
					break;
				}
			}
			else if (!_stricmp(token, "add"))
			{
				char src[32];
				if (!parser.GetNextToken(src, 32))
				{
					parseError = PARSER_ERROR_INVALID_SRC_OPERAND;
					break;
				}

				instr->SetMnemonic(TISM_ADD);
				if (!instr->SetSource(src))
				{
					parseError = PARSER_ERROR_INVALID_SRC_OPERAND;
				}
			}
			else if (!_stricmp(token, "sub"))
			{
				char src[32];
				if (!parser.GetNextToken(src, 32))
				{
					parseError = PARSER_ERROR_INVALID_SRC_OPERAND;
					break;
				}

				instr->SetMnemonic(TISM_SUB);
				if (!instr->SetSource(src))
				{
					parseError = PARSER_ERROR_INVALID_SRC_OPERAND;
				}
			}
			else if (!_stricmp(token, "neg"))
			{
				instr->SetMnemonic(TISM_NEG);
			}
			else if (!_stricmp(token, "sav"))
			{
				instr->SetMnemonic(TISM_SAV);
			}
			else if (!_stricmp(token, "swp"))
			{
				instr->SetMnemonic(TISM_SWP);
			}
			else if (!_stricmp(token, "jmp"))
			{
				char target[32];
				if (!parser.GetIdentifier(target, 32))
				{
					parseError = PARSER_ERROR_MISSING_JMP_TARGET;
					break;
				}

				instr->SetMnemonic(TISM_JMP);
				instr->SetJumpTarget(target);
			}
			else if (!_stricmp(token, "jro"))
			{
				char src[32];
				if (!parser.GetNextToken(src, 32))
				{
					parseError = PARSER_ERROR_MISSING_JMP_TARGET;
					break;
				}

				instr->SetMnemonic(TISM_JRO);
				instr->SetSource(src);
			}
			else if (!_stricmp(token, "jez"))
			{
				char target[32];
				if (!parser.GetIdentifier(target, 32))
				{
					parseError = PARSER_ERROR_MISSING_JMP_TARGET;
					break;
				}

				instr->SetMnemonic(TISM_JEZ);
				instr->SetJumpTarget(target);
			}
			else if (!_stricmp(token, "jnz"))
			{
				char target[32];
				if (!parser.GetIdentifier(target, 32))
				{
					parseError = PARSER_ERROR_MISSING_JMP_TARGET;
					break;
				}

				instr->SetMnemonic(TISM_JNZ);
				instr->SetJumpTarget(target);
			}
			else if (!_stricmp(token, "jgz"))
			{
				char target[32];
				if (!parser.GetIdentifier(target, 32))
				{
					parseError = PARSER_ERROR_MISSING_JMP_TARGET;
					break;
				}

				instr->SetMnemonic(TISM_JGZ);
				instr->SetJumpTarget(target);
			}
			else if (!_stricmp(token, "jlz"))
			{
				char target[32];
				if (!parser.GetIdentifier(target, 32))
				{
					parseError = PARSER_ERROR_MISSING_JMP_TARGET;
					break;
				}

				instr->SetMnemonic(TISM_JLZ);
				instr->SetJumpTarget(target);
			}
			else
			{
				parseError = PARSER_ERROR_UNKNOWN_INSTRUCTION;
				break;
			}
		}

		if (parseError == PARSER_NO_ERROR)
		{
			instructionList.push_back(instr);
		}
		else
		{
			// TODO: Print the error (preferably with a line number).
			break;
		}
	}

	delete[] buffer;

	return parseError == PARSER_NO_ERROR;
}

bool VerifyLabels(const std::vector<TIS100Instruction*>& instructionList)
{
	std::vector<TIS100Instruction*>::const_iterator curInstrIt, curInstrItLast = instructionList.end();
	for (curInstrIt = instructionList.begin(); curInstrIt != curInstrItLast; ++curInstrIt)
	{
		TIS100Instruction* curInstruction = *curInstrIt;
		if (!curInstruction->IsJump() || curInstruction->GetMnemonic() == TISM_JRO)
		{
			continue;
		}

		const char* jumpTarget = curInstruction->GetJumpTarget();

		// Search for the label.
		bool found = false;
		std::vector<TIS100Instruction*>::const_iterator labelInstrIt, labelInstrItLast = instructionList.end();
		for (labelInstrIt = instructionList.begin(); labelInstrIt != labelInstrItLast;++labelInstrIt)
		{
			const char* label = (*labelInstrIt)->GetLabel();
			if (!label)
			{
				continue;
			}

			if (!_stricmp(label, jumpTarget))
			{
				found = true;
				break;
			}
		}

		if (!found)
		{
			printf("Label \"%s\" not found.\n", jumpTarget);
			return false;
		}
	}

	return true;
}

Program* Assemble(std::vector<TIS100Instruction*>& instructionList)
{
	Program* prog = new Program();

	std::vector<TIS100Instruction*>::iterator curInstrIt, curInstrItLast = instructionList.end();
	for (curInstrIt = instructionList.begin(); curInstrIt != curInstrItLast; ++curInstrIt)
	{
		TIS100Instruction* instr = *curInstrIt;

		const char* label = instr->GetLabel();
		if (label)
		{
			prog->AddLabel(label);
		}

		switch (instr->GetMnemonic())
		{
		case TISM_NOP:
			prog->AddMicroInstruction(new MicroInstruction(MIM_ADD, MID_NIL, MIS_NIL, MIS_NIL));
			break;
		case TISM_MOV:
			switch (instr->GetSource())
			{
			case TISS_IMM:
				if (instr->IsDestinationPort())
				{
					// MOV imm, port => WRP port, imm
					prog->AddMicroInstruction(new MicroInstruction(MIM_WRP, TIStoMIDestination(instr->GetDestination()), MIS_NIL, instr->GetImmediate()));
				}
				else
				{
					// MOV imm, reg => ADD reg, NIL, imm
					prog->AddMicroInstruction(new MicroInstruction(MIM_ADD, TIStoMIDestination(instr->GetDestination()), MIS_NIL, instr->GetImmediate()));
				}
				break;
			case TISS_PORT_UP:
			case TISS_PORT_DOWN:
			case TISS_PORT_LEFT:
			case TISS_PORT_RIGHT:
			case TISS_PORT_ANY:
			case TISS_PORT_LAST:
				if (instr->IsDestinationPort())
				{
					// MOV portS, portD => RDP TMP, portS; WRP portD, TMP;
					prog->AddMicroInstruction(new MicroInstruction(MIM_RDP, MID_TMP, TIStoMISource(instr->GetSource()), MIS_NIL));
					prog->AddMicroInstruction(new MicroInstruction(MIM_WRP, TIStoMIDestination(instr->GetDestination()), MIS_TMP, MIS_NIL));
				}
				else
				{
					// MOV port, reg => RDP reg, port
					prog->AddMicroInstruction(new MicroInstruction(MIM_RDP, TIStoMIDestination(instr->GetDestination()), TIStoMISource(instr->GetSource()), MIS_NIL));
				}
				break;
			case TISS_ACC:
			case TISS_NIL:
				if (instr->IsDestinationPort())
				{
					// MOV reg, port => WRP port, reg
					prog->AddMicroInstruction(new MicroInstruction(MIM_WRP, TIStoMIDestination(instr->GetDestination()), TIStoMISource(instr->GetSource()), MIS_NIL));
				}
				else
				{
					// MOV regS, regD => ADD regD, NIL, regS
					prog->AddMicroInstruction(new MicroInstruction(MIM_ADD, TIStoMIDestination(instr->GetDestination()), MIS_NIL, TIStoMISource(instr->GetSource())));
				}
				break;
			}
			break;
		case TISM_ADD:
			switch (instr->GetSource())
			{
			case TISS_IMM:
				// ADD imm => ADD ACC, ACC, imm
				prog->AddMicroInstruction(new MicroInstruction(MIM_ADD, MID_ACC, MIS_ACC, instr->GetImmediate()));
				break;
			case TISS_PORT_UP:
			case TISS_PORT_DOWN:
			case TISS_PORT_LEFT:
			case TISS_PORT_RIGHT:
			case TISS_PORT_ANY:
			case TISS_PORT_LAST:
				// ADD port => RDP TMP, port; ADD ACC, ACC, TMP
				prog->AddMicroInstruction(new MicroInstruction(MIM_RDP, MID_TMP, TIStoMISource(instr->GetSource()), MIS_NIL));
				prog->AddMicroInstruction(new MicroInstruction(MIM_ADD, MID_ACC, MIS_ACC, MIS_TMP));
				break;
			case TISS_ACC:
			case TISS_NIL:
				// ADD reg => ADD ACC, ACC, reg
				prog->AddMicroInstruction(new MicroInstruction(MIM_ADD, MID_ACC, MIS_ACC, TIStoMISource(instr->GetSource())));
				break;
			}
			break;
		case TISM_SUB:
			switch (instr->GetSource())
			{
			case TISS_IMM:
				// SUB imm => ADD ACC, ACC, imm
				prog->AddMicroInstruction(new MicroInstruction(MIM_SUB, MID_ACC, MIS_ACC, instr->GetImmediate()));
				break;
			case TISS_PORT_UP:
			case TISS_PORT_DOWN:
			case TISS_PORT_LEFT:
			case TISS_PORT_RIGHT:
			case TISS_PORT_ANY:
			case TISS_PORT_LAST:
				// SUB port => RDP TMP, port; SUB ACC, ACC, TMP
				prog->AddMicroInstruction(new MicroInstruction(MIM_RDP, MID_TMP, TIStoMISource(instr->GetSource()), MIS_NIL));
				prog->AddMicroInstruction(new MicroInstruction(MIM_SUB, MID_ACC, MIS_ACC, MIS_TMP));
				break;
			case TISS_ACC:
			case TISS_NIL:
				// SUB reg => SUB ACC, ACC, reg
				prog->AddMicroInstruction(new MicroInstruction(MIM_SUB, MID_ACC, MIS_ACC, TIStoMISource(instr->GetSource())));
				break;
			}
			break;
		case TISM_NEG:
			prog->AddMicroInstruction(new MicroInstruction(MIM_NEG, MID_ACC, MIS_ACC, 1));
			break;
		case TISM_SAV:
			prog->AddMicroInstruction(new MicroInstruction(MIM_ADD, MID_BAK, MIS_ACC, MIS_NIL));
			break;
		case TISM_SWP:
//			prog->AddMicroInstruction(new MicroInstruction(MIM_ADD, MID_TMP, MIS_ACC, MIS_NIL));
//			prog->AddMicroInstruction(new MicroInstruction(MIM_ADD, MID_ACC, MIS_BAK, MIS_NIL));
//			prog->AddMicroInstruction(new MicroInstruction(MIM_ADD, MID_BAK, MIS_TMP, MIS_NIL));

			prog->AddMicroInstruction(new MicroInstruction(MIM_SWP, MID_NIL, MIS_NIL, MIS_NIL));
			break;
		case TISM_JMP:
			prog->AddMicroInstruction(new MicroInstruction(MIM_JMP, MID_NIL, MIS_ACC, prog->FindLabelOffset(instr->GetJumpTarget())));
			break;
		case TISM_JEZ:
			prog->AddMicroInstruction(new MicroInstruction(MIM_JEZ, MID_NIL, MIS_ACC, prog->FindLabelOffset(instr->GetJumpTarget())));
			break;
		case TISM_JNZ:
			prog->AddMicroInstruction(new MicroInstruction(MIM_JNZ, MID_NIL, MIS_ACC, prog->FindLabelOffset(instr->GetJumpTarget())));
			break;
		case TISM_JGZ:
			prog->AddMicroInstruction(new MicroInstruction(MIM_JGZ, MID_NIL, MIS_ACC, prog->FindLabelOffset(instr->GetJumpTarget())));
			break;
		case TISM_JLZ:
			prog->AddMicroInstruction(new MicroInstruction(MIM_JLZ, MID_NIL, MIS_ACC, prog->FindLabelOffset(instr->GetJumpTarget())));
			break;
		case TISM_JRO:
			switch (instr->GetSource())
			{
			case TISS_IMM:
				// JRO imm
				prog->AddMicroInstruction(new MicroInstruction(MIM_JRO, MID_NIL, MIS_ACC, instr->GetImmediate()));
				break;
			case TISS_PORT_UP:
			case TISS_PORT_DOWN:
			case TISS_PORT_LEFT:
			case TISS_PORT_RIGHT:
			case TISS_PORT_ANY:
			case TISS_PORT_LAST:
				// JRO port => RDP TMP, port; JRO TMP
				prog->AddMicroInstruction(new MicroInstruction(MIM_RDP, MID_TMP, TIStoMISource(instr->GetSource()), MIS_NIL));
				prog->AddMicroInstruction(new MicroInstruction(MIM_JRO, MID_NIL, MIS_ACC, MIS_TMP));
				break;
			case TISS_ACC:
			case TISS_NIL:
				// JRO reg
				prog->AddMicroInstruction(new MicroInstruction(MIM_JRO, MID_NIL, MIS_ACC, TIStoMISource(instr->GetSource())));
				break;
			}
			break;
		default:
			break;
		}
	}

	prog->FixForwardJumps();

	return prog;
}

bool WriteProg(const char* filename, Program* prog)
{
	unsigned int* imem = prog->GetCode();

	FILE* f = fopen(filename, "w");
	if (!f)
	{
		return false;
	}

	unsigned int numInstructions = prog->GetNumInstructions();
	for (unsigned int i = 0; i < numInstructions; ++i)
	{
		fprintf(f, "%08X\n", imem[i]);
	}

	fclose(f);

	return true;
}

int main(int argc, char** argv)
{
	// TODO: Parse input arguments

	const char* inputFile = "multiply.tis";
	const char* outputFile = "multiply.prg";

	// Parse input file and retrieve all the instructions
	std::vector<TIS100Instruction*> instructionList;
	if (!ParseTISFile(inputFile, instructionList))
	{
		printf("Failed to parse %s as TIS assembly file.\n", inputFile);
		return -1;
	}

	// Check if all labels are present in the program
	if (!VerifyLabels(instructionList))
	{
		printf("Failed to verify program labels.\n");
		return -1;
	}

	// Assemble the instruction list into a program
	Program* prog = Assemble(instructionList);
	if (!prog)
	{
		printf("Failed to assemble program.\n");
		return -1;
	}

	// Write the final instruction list to the outputFile.
	if (!WriteProg(outputFile, prog))
	{
		printf("Failed to write program to file.\n");
		return -1;
	}

	return 0;
}
