
////////////////////////////////////////////
////////////generator///////////////////////
class generator extends uvm_sequence #(transaction);
  `uvm_object_utils(generator)
  transaction t;
  transaction temp;
  transaction write_array[int];
  int id_array[$];
  int count;
  int i;
  function new(input string path="GEN");
    super.new(path);
    $display("sequencer created");
    count=$urandom_range(10,20);
  endfunction
  ////////////////////////////////////////
  function void add_element(transaction t);
    temp=new t;
    write_array[t.id]=temp;
  endfunction
      
  ////////////////////////////////////////////
  virtual task body();
    i=0;
    repeat(count) begin
      t=transaction::type_id::create("t");
      start_item(t);
      t.randomize();
      add_element(t);//storing the transaction object
      //id_array[$urandom_range(0,count)]=t.id;//storing the elements in the array
      id_array.push_front(t.id);
      finish_item(t);
      i=i+1;
    end 
    `uvm_warning("SEQR","write task is done Proceeding to the read");
    id_array.shuffle();
    foreach(id_array[i]) begin
      write_array[id_array[i]].read=1;
      write_array[id_array[i]].display("SEQR");
      start_item(write_array[id_array[i]]);
      finish_item(write_array[id_array[i]]);
    end
  endtask
  
endclass