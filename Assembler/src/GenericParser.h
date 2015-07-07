#ifndef GenericParser_h
#define GenericParser_h

class GenericParser
{
public:
	GenericParser(const char* stringForParsing) : m_String(stringForParsing), m_CurPos(0)
	{};

	~GenericParser()
	{};

	char GetNextChar(void);
	const char* GetParsedString(void) const;

	bool GetNextToken(char* string, unsigned int size);
	bool GetIdentifier(char* string, unsigned int size);
	bool GetString(char* string, int length);
	bool GetFloat(float& value);
	bool GetInteger(int& value);
	bool GetBoolean(bool& value);

	bool Expecting(char character);

	void SkipWhiteSpaces(void);
	void SkipComments(void);

	// These functions don't depend on the current parser state (or the string to be parsed)
	// so making them static might help somewhere outside of the parser.
	static bool IsWhiteSpace(char c);
	static bool IsNumber(char c);
	static bool IsAlphaUnderscore(char c);

private:
	const char* m_String;
	unsigned int m_CurPos;
};

//////////////////////////////////////////////////////////////////////////
// Inline functions...
//
inline char GenericParser::GetNextChar(void)
{
	SkipComments();
	return m_String[m_CurPos];
}

inline const char* GenericParser::GetParsedString(void) const
{
	return m_String;
}

#endif