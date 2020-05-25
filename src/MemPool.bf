using System;

namespace tinyxml2
{
	sealed class MemPool<T> where T: XmlNode
	{
		private int _currentAllocs;
		private int _nAllocs;
		private int _maxAllocs;
		private int _nUntracked;

		[Union]
		private struct Item
		{
			public Item* next;
			public char8[20] itemData;
		}

		[Union]
		private struct Block
		{
			Item[20] items; 
		}

		public void Clear()
		{

		}
	}
}
