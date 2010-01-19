/* Copyright (c) 2009 Shlomi Fish
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */
/*
 * find_opt.cs - this C# code implements the algorithm put forth here:
 * 
 * http://tech.groups.yahoo.com/group/fc-solve-discuss/message/1026
 * 
 * Try to find a near-optimal allocation of quotas for a switch-tasked
 * Freecell run, incrementally.
 * 
 * */

using System.Collections.Generic;
using System;
using System.IO;

class Quota_Allocation
{
	public int scan_idx;
	public int quota;
	
	public Quota_Allocation(int new_scan_idx, int new_quota)
	{
		scan_idx = new_scan_idx;
		quota = new_quota;
	}
	
	public Quota_Allocation(Quota_Allocation other)
	{
		scan_idx = other.scan_idx;
		quota = other.quota;
	}
}

class InputScan
{
	public int id;
	public string cmd_line;
	
	public InputScan(int new_id, string new_cmd_line)
	{
		id = new_id;
		cmd_line = new_cmd_line;
	}
	
	static public InputScan from_line(string line)
	{
		string [] e = line.Split('\t');
		return new InputScan(Convert.ToInt32(e[0]), e[1]);
	}
}

class Input
{
	public int start_board;
	public int num_boards;
	
	public const string data_dir
		= "/home/shlomi/progs/freecell/trunk/fc-solve/presets/soft-threads/meta-moves/auto-gen";
	
	public List<int> blacklist;
	public List<InputScan> scans;
	
	public InputScan [] scans_arr;
	
	public int [,] scans_data;
	
	public Input(int new_start_board, int new_num_boards)
	{
		start_board = new_start_board;
		num_boards = new_num_boards;
	}
	
	public string data_file_path(string basename)
	{
		return data_dir + "/" + basename;
	}
	
	public void read_scan_black_list()
	{
		blacklist = new List<int>();
		StreamReader f = new StreamReader(data_file_path("scans-black-list.txt"));
		
     	string line;
		
        while ((line = f.ReadLine()) != null) 
        {
      		blacklist.Add(Convert.ToInt32(line));
        }
	}
	
	public void read_scans_file()
	{
		scans = new List<InputScan>();
		read_scan_black_list();
		StreamReader f = new StreamReader(data_file_path("scans.txt"));
		
		string line;

        while ((line = f.ReadLine()) != null) 
        {
			InputScan scan = InputScan.from_line(line);
			
			if (! blacklist.Exists(i => i == scan.id))
			{
				scans.Add(scan);
			}
        }		
		
		calc_scan_array();
	}
	
	public void read_data()
	{
		read_scans_file();
		
		scans_data = new int [scans.Count,num_boards];
		
		int scan_idx = 0;
		foreach (InputScan scan in scans)
		{
			string file_path = 
				data_file_path("data/" + scan.id + ".data.bin");
			
			BinaryReader binReader =
			    new BinaryReader(File.Open(file_path, FileMode.Open));
			
			{
				int start, num, iters_limit;
			
				start = binReader.ReadInt32();
				num = binReader.ReadInt32();
				iters_limit = binReader.ReadInt32();
				
				if (start != start_board)
				{
					throw new ArgumentException("Start board does not match in " + scan.id);
				}
				
				if (num != num_boards)
				{
					throw new ArgumentException("Num boards does not match in " + scan.id);
				}
				
				if (iters_limit != 100000)
				{
					throw  new ArgumentException("Iters limits is wrong in scan No. " + scan.id);
				}
			}
			
			for (int board_idx = 0; board_idx < num_boards ; board_idx++)
			{
				scans_data[scan_idx,board_idx] = binReader.ReadInt32();				
			}

			scan_idx++;
		}
	}

	protected void calc_scan_array()
	{
		scans_arr = new InputScan[scans.Count];
		
		int scan_idx = 0;
		foreach (InputScan scan in scans)
		{
			scans_arr[scan_idx++] = scan;
		}
	}
	
	public string FormatQuota(Quota_Allocation quota_a)
	{
		return 
			string.Format(
				"{0}@{1}", quota_a.quota, scans_arr[quota_a.scan_idx].id
		    );
	}
}


class Process
{
	protected Input input;
	
	public Process(Input new_input)
	{
		input = new_input;
	}
	
	protected int [] get_default_quotas(int quota_iters_num)
	{
		const int default_quota = 350;
		
		return get_constant_quotas(quota_iters_num, default_quota);
	}
	
	protected int [] get_constant_quotas(int quota_iters_num, int quota_value)
	{
		int [] quotas = new int[quota_iters_num];
		
		for (int i = 0; i < quota_iters_num ; i++)
		{
			quotas[i] = quota_value;
		}

		return quotas;
	}

	public void SampleRunWithConstantQuotas(int quota_value)
	{
		const int quota_iters_num = 5000;
				
		long total_iters = -1;
		List<Quota_Allocation> rled_allocs = null;
		
		GetQuotasAllocation(quota_iters_num,
		                    get_constant_quotas(quota_iters_num, quota_value),
		                    ref rled_allocs,
		                    ref total_iters
		                    );
		
		Console.WriteLine("total_iters = " + total_iters);
		
		print_quota_allocations(rled_allocs);
	}
	
	public void SampleRun()
	{
		const int quota_iters_num = 5000;
				
		long total_iters = -1;
		List<Quota_Allocation> rled_allocs = null;
		
		GetQuotasAllocation(quota_iters_num,
		                    get_default_quotas(quota_iters_num), 
		                    ref rled_allocs,
		                    ref total_iters
		                    );
		
		Console.WriteLine("total_iters = " + total_iters);
		
		print_quota_allocations(rled_allocs);
	}

	void print_quota_allocations (System.Collections.Generic.List<Quota_Allocation> rled_allocs)
	{
		bool is_first = true;
		
		foreach (Quota_Allocation quota_a in rled_allocs)
		{
			if (! is_first)
			{
				Console.Write(",");
			}
			
			Console.Write(input.FormatQuota(quota_a));
			
			is_first = false;
		}
		Console.WriteLine("");
	}

	
	public void GetQuotasAllocation(int quota_iters_num,
	                                int [] quotas,
	                                ref List<Quota_Allocation> rled_allocs,
	                                ref long total_iters
	                                )
	{
		List<Quota_Allocation> allocations = new List<Quota_Allocation>();
			
		int scans_num = input.scans.Count;
	
		int [,] running_scans_data = input.scans_data;
		
		int num_boards = input.num_boards;
		
		int quota = 0;
		
		total_iters = 0;
		
		for (int quota_idx = 0; quota_idx < quota_iters_num ; quota_idx++)
		{	
			quota += quotas[quota_idx];
			
			int max_solved_boards = 0;
			int max_solved_scan_idx = -1;
			
			/*
			 * Find the scan which solves the largest number of boards.
			 * */
			for (int scan_idx = 0; scan_idx < scans_num ; scan_idx++)
			{
				int solved_boards = 0;
				
				for (int board_idx = 0; board_idx < num_boards ; board_idx++)
				{
					int datum = running_scans_data[scan_idx, board_idx];
					
					if ((datum > 0) && (datum <= quota))
					{
						solved_boards++;
					}
				}

#if false
				Console.WriteLine ("Scan idx is " + scan_idx);
				Console.WriteLine(
					string.Format(
				    	"Solved {0} boards at scan {1} at quota_idx {2}",
				        solved_boards, scans[scan_idx].id, quota_idx
				    )
			    );
#endif
				
				if (solved_boards > max_solved_boards)
				{
					max_solved_boards = solved_boards;
					max_solved_scan_idx = scan_idx;
				}
			}
			
			if (max_solved_boards > 0)
			{
				allocations.Add(new Quota_Allocation(max_solved_scan_idx, quota));
				
				/* Update the iterations */
				
				int [,] new_running_scans_data =
					new int [scans_num , num_boards-max_solved_boards];
				int target_idx = 0;
				
				total_iters += num_boards * quota;
				
				for(int board_idx = 0; board_idx < num_boards; board_idx++)
				{
					int source_max_datum = running_scans_data[max_solved_scan_idx,board_idx];

					if ((source_max_datum < 0) || (source_max_datum > quota))
					{
						for (int scan_idx = 0; scan_idx < scans_num ; scan_idx++)
						{
							int source_datum =
								running_scans_data[scan_idx,board_idx];
						
							new_running_scans_data[scan_idx, target_idx] = 
								((max_solved_scan_idx == scan_idx)
									? (source_datum - quota) : source_datum
								);
						}
					
						target_idx++;
					}
					else
					{
						/* We only iterated for source_max_datum iterations for 
						 * scan_idx == max_solved_scan_idx 
						 * */
						total_iters -= (quota-source_max_datum);
					}
				}
				
				/* This is an assertion. */
				if (target_idx != num_boards-max_solved_boards)
				{
					throw new ApplicationException("target_idx is not max_solved_boards");
				}
				
				running_scans_data = new_running_scans_data;
			    num_boards = target_idx;
				
				quota = 0;
			}
		}
		
		rled_allocs = run_length_encode_allocations(allocations);
	}

	protected List<Quota_Allocation> run_length_encode_allocations (List<Quota_Allocation> allocations)
	{
		List<Quota_Allocation> rled_allocs = new List<Quota_Allocation>();
			/* RLE the allocations */
			
		Quota_Allocation to_add = null;
		foreach (Quota_Allocation item in allocations)
		{
			if (to_add == null)
			{
				to_add = new Quota_Allocation(item);
			}
			else
			{
				if (to_add.scan_idx == item.scan_idx)
				{
					to_add.quota += item.quota;
				}
				else
				{
					rled_allocs.Add(to_add);
					to_add = new Quota_Allocation(item);
				}
			}
		}
		rled_allocs.Add(to_add);
		
		return rled_allocs;
	}
	
	public void FindOptimalQuotas(int quota_iters_num)
	{	
		const int initial_quota_value = 350;
		
		const int start_quota = 100;
		const int end_quota = 1000;
		
		List<Quota_Allocation> rled_allocs = null;
				
		int [] running_quotas = get_constant_quotas(quota_iters_num, initial_quota_value);
		
		for(int quota_idx = 0; quota_idx < quota_iters_num ; quota_idx++)
		{
			int min_quota = -1;
			long min_quota_iters = -1;
			for (int quota_value = start_quota; quota_value <= end_quota ; quota_value++)
			{
				if (quota_value % 50 == 0)
				{
					Console.WriteLine("Reached " + quota_value);
				}
				running_quotas[quota_idx] = quota_value;
				
				long iters = -1;
				
				GetQuotasAllocation(quota_iters_num,
				                    running_quotas,
				                    ref rled_allocs,
				                    ref iters);
				    
        		if ((min_quota_iters < 0) || (iters < min_quota_iters))
        		{
            		min_quota = quota_value;
            		min_quota_iters = iters;
        		}
			}
			
			running_quotas[quota_idx] = min_quota;
			
#if true
			/* A trace. */
			Console.WriteLine(string.Format("Found {0} for No. {1} ({2})",
			                                min_quota,
			                                quota_idx,
			                                min_quota_iters));
#endif

		}
	}
	
}

class Program
{
	const int start_board = 1;
	const int num_boards = 32000;
	
    static void Main(string[] args)
    {
		string cmd = ((args.Length >= 1) ? args[0] : "");
		if (cmd == "test_blacklist")
		{
			Input i = new Input(start_board, num_boards);
			i.read_scan_black_list();
			
			foreach (int blacked in i.blacklist)
			{
				Console.WriteLine(blacked);
			}
		}
		else if (cmd == "test_lookup_scan_cmd_line_by_id")
		{
			Input input = new Input(start_board, num_boards);
			input.read_scans_file();
			
			int id = Convert.ToInt32(args[1]);
			
			InputScan scan = input.scans.Find(e => e.id == id);
			Console.WriteLine(scan.cmd_line);
		}
		else if (cmd == "test_lookup_iters")
		{
			Input input = new Input(start_board, num_boards);
			input.read_data();
			
			int scan_id = Convert.ToInt32(args[1]);
			int board_idx = Convert.ToInt32(args[2]);
			
			int scan_idx = 0;
			foreach (InputScan scan in input.scans)
			{
				if (scan.id == scan_id)
				{
					break;
				}
				scan_idx++;
			}
			
			Console.WriteLine(input.scans_data[scan_idx , (board_idx-input.start_board)]);
		}
        else if (cmd == "test_process_sample_run")
        {
            Input input = new Input(start_board, num_boards);
            input.read_data();

            Process p = new Process(input);
            p.SampleRun();
        }
		else if (cmd == "test_process_sample_run_with_constant_quotas")
		{
            Input input = new Input(start_board, num_boards);
            input.read_data();
			
			int quota_value = Convert.ToInt32(args[1]);

            Process p = new Process(input);
            p.SampleRunWithConstantQuotas(quota_value);
		}
		else if (cmd == "find_optimal_quotas")
		{
            Input input = new Input(start_board, num_boards);
            input.read_data();
			
			int iters_num = Convert.ToInt32(args[1]);

            Process p = new Process(input);
            p.FindOptimalQuotas(iters_num);
		}		
        // List<double> myList = new List<double>();
		else
		{
        	Console.WriteLine("Hello World!");
		}
    }
}
