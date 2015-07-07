#ifndef Program_h
#define Program_h

class MicroInstruction;

#include <vector>
#include <map>
#include <string>

class Program
{
public:
	Program();
	~Program();

	void AddMicroInstruction(MicroInstruction* mi);
	void AddLabel(const char* label);
	int FindLabelOffset(const char* label);

	bool FixForwardJumps();

	unsigned int* GetCode() const;
	unsigned int GetNumInstructions() const;

private:
	typedef std::vector<MicroInstruction*> _MicroInstrList;
	typedef std::map<std::string, int> _LabelMap;

	_MicroInstrList m_InstructionList;
	_LabelMap m_LabelMap;
	_LabelMap m_UnknownLabels; // Used by labels ahead of the current instruction.
	int m_NextUnknownLabelID;
};

//////////////////////////////////////////////////////////////////////////
// Inline functions...
//
inline unsigned int Program::GetNumInstructions() const
{
	return m_InstructionList.size();
}

#endif
