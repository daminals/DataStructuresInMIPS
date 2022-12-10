import org.junit.*;
import org.junit.rules.Timeout;

// me
import java.util.*;
import java.io.*;
// me
import java.util.concurrent.TimeUnit;

import static edu.gvsu.mipsunit.munit.MUnit.Register.*;
import static org.junit.Assert.assertEquals;
import static edu.gvsu.mipsunit.munit.MUnit.*;
import static edu.gvsu.mipsunit.munit.MARSSimulator.*;

import org.junit.rules.Timeout;
import java.util.concurrent.TimeUnit;

public class CustomTest {

  private int reg_sp = 0;
  private int reg_s0 = 0;
  private int reg_s1 = 0;
  private int reg_s2 = 0;
  private int reg_s3 = 0;
  private int reg_s4 = 0;
  private int reg_s5 = 0;
  private int reg_s6 = 0;
  private int reg_s7 = 0;

  @Before
  public void preTest() {
    this.reg_s0 = get(s0);
    this.reg_s1 = get(s1);
    this.reg_s2 = get(s2);
    this.reg_s3 = get(s3);
    this.reg_s4 = get(s4);
    this.reg_s5 = get(s5);
    this.reg_s6 = get(s6);
    this.reg_s7 = get(s7);
    this.reg_sp = get(sp);
  }

  public static String getStringFromNode(int addy, int len) {
    return getString(addy + 4, len);
  }

  @After
  public void postTest() {
    Assert.assertEquals("Register convention violated $s0", this.reg_s0, get(s0));
    Assert.assertEquals("Register convention violated $s1", this.reg_s1, get(s1));
    Assert.assertEquals("Register convention violated $s2", this.reg_s2, get(s2));
    Assert.assertEquals("Register convention violated $s3", this.reg_s3, get(s3));
    Assert.assertEquals("Register convention violated $s4", this.reg_s4, get(s4));
    Assert.assertEquals("Register convention violated $s5", this.reg_s5, get(s5));
    Assert.assertEquals("Register convention violated $s6", this.reg_s6, get(s6));
    Assert.assertEquals("Register convention violated $s7", this.reg_s7, get(s7));
    Assert.assertEquals("Register convention violated $sp", this.reg_sp, get(sp));
  }

  @Rule
  public Timeout timeout = new Timeout(30000, TimeUnit.MILLISECONDS);

  @Test
  public void create_network_1() {
    int I = 5;
    int J = 10;
    run("create_network", I, J);
    int heapsize = 4 + I + J;
    int addy = get(v0);
    Assert.assertEquals(I, getWord(addy));
    Assert.assertEquals(J, getWord(addy + 4));
    for (int k = 2; k < heapsize * 4; k++)
      Assert.assertEquals(0, getWord(addy + k * 4));
  }

  @Test
  public void create_network_2() {
    int I = -5;
    int J = 10;
    run("create_network", I, J);
    // int heapsize = 4 + I + J;
    Assert.assertEquals(-1, get(v0));
  }

  @Test
  public void create_network_3() {
    int I = 9;
    int J = 3;
    run("create_network", I, J);
    int heapsize = 4 + I + J;
    int addy = get(v0);
    Assert.assertEquals(I, getWord(addy));
    Assert.assertEquals(J, getWord(addy + 4));
    for (int k = 2; k < heapsize * 4; k++)
      Assert.assertEquals(0, getWord(addy + k * 4));
  }

  @Test
  public void create_network_4() {
    int I = 2;
    int J = 1;
    run("create_network", I, J);
    int heapsize = 4 + I + J;
    int addy = get(v0);
    Assert.assertEquals(I, getWord(addy));
    Assert.assertEquals(J, getWord(addy + 4));
    for (int k = 2; k < heapsize * 4; k++)
      Assert.assertEquals(0, getWord(addy + k * 4));
  }

  @Test
  public void add_person_1() {
    int I = 5;
    int J = 10;
    run("create_network", I, J);
    int heapsize = 4 + I + J;
    int addy = get(v0);
    String name = "Stanislav";
    Label Asciiname = asciiData(true, name);
    Label address = wordData(getWords(addy, heapsize * 4));
    run("add_person", address, Asciiname);
    Assert.assertEquals(address.address(), get(v0));
    Assert.assertEquals(1, get(v1));
    int[] newNetwork = {5, 10, 1, 0};
    for (int k = 0; k < 4; k++)  Assert.assertEquals(newNetwork[k],getWord(address, 4*k));  
    // for (int k = 0; k < heapsize * 4; k++)  System.out.print(getWord(address, 4*k) + " ");  
    // System.out.println("\n");  
    int st = getWord(address, 4*4); // this is the start of the struct
    // struct = {0:char_num, 4+:char[]}
    String savedName = getString(st+4, name.length());
    Assert.assertEquals(savedName.length(), getWord(st));
    Assert.assertEquals(name, savedName);
  }

  @Test
  public void add_person_2() {
    // test empty name
    int I = 5;
    int J = 10;
    run("create_network", I, J);
    int heapsize = 4 + I + J;
    int addy = get(v0);
    Label name = asciiData(true, "\0");
    Label address = wordData(getWords(addy, heapsize * 4));
    run("add_person", address, name);
    Assert.assertEquals(-1, get(v1));
    Assert.assertEquals(-1, get(v0));
  }

  @Test
  public void add_person_3() {
    // same name dilemma
    int I = 5;
    int J = 10;
    int heapsize = 4 + I + J;
    String asciiname = "Bethany";
    // can't add bethany twice
    run("create_network", I, J);
    Label address = wordData(getWords(get(v0), heapsize * 4));
    Label name1 = asciiData(true, asciiname);
    Label name2 = asciiData(true, asciiname);
    Label buffer = wordData(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    // cannot access heap twice. run special command in test file: temp.asm
    run("add_person_3", address, name1, name2, buffer);
    int[] expectedAns = {address.address(), 1, -1, -1};
    for (int i=0; i<expectedAns.length; i++) Assert.assertEquals(expectedAns[i], getWord(buffer,i*4));
  }

  @Test
  public void add_person_4() {
    // add more people than allowed
    int I = 5;
    int J = 10;
    int heapsize = 4 + I + J;
    run("create_network", I, J);
    Label address = wordData(getWords(get(v0), heapsize * 4));

    String[] names = {"Athena", "Jezzebelle", "Sparticus", "Quigley", "Caledonia"};
    Label name_buffer = asciiData("Athena\0", "Jezzebelle\0", "Sparticus\0", "Quigley\0", "Caledonia\0", "Demetrius\0");
    // create a buffer to hold answers
    Label ans_buffer = wordData(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    run("add_person_4", address, name_buffer, ans_buffer);
    // System.out.println(ans_buffer.address());
    // for (int i=0; i<12; i++) System.out.println(getWord(ans_buffer, i*4));
    for (int i=0; i<10; i+=2) Assert.assertEquals(address.address(), getWord(ans_buffer, i*4));
    for (int i=1; i<11; i+=2) Assert.assertEquals(1, getWord(ans_buffer, i*4));
    Assert.assertEquals(-1, getWord(ans_buffer, 10*4));
    Assert.assertEquals(-1, getWord(ans_buffer, 11*4));
    for (int i=0; i<names.length; i++) Assert.assertEquals(names[i], getString(getWord(address.address() + 16 + i*4)+4));
    // for (int i=0; i<names.length; i++)  System.out.println(getString(getWord(address.address() + 16 + i*4)+4));
  }

  @Test
  public void get_person_1() {
    // get persons name: returns person node
    int I = 5;
    int J = 10;
    run("create_network", I, J);
    int heapsize = 4 + I + J;
    Label addy = wordData(getWords(get(v0), heapsize * 4));
    String asciiname = "Bethany";
    Label name = asciiData(true, asciiname);
    run("get_person_1", addy, name);
    // find bethany (she must be found) // should only be one person in heap
    Assert.assertNotEquals(-1, get(v0));
    Assert.assertEquals(asciiname, getString(get(v0)+4,asciiname.length()));
    Assert.assertEquals(1, get(v1));
  }

  @Test
  public void get_person_2() {
    // get persons name: returns -1 person not in network
    int I = 5;
    int J = 10;
    run("create_network", I, J);
    int heapsize = 4 + I + J;
    Label addy = wordData(getWords(get(v0), heapsize * 4));
    String asciiname = "Bethany";
    Label name = asciiData(true, asciiname);
    run("get_person", addy, name);
    // find bethany (she must NOT be found) // should only be one person in heap
    Assert.assertEquals(-1, get(v1));
    Assert.assertEquals(-1, get(v0));
  }

  @Test
  public void add_relationship_1() {
    // creates an edge
    int I = 4;
    int J = 6;
    run("create_network", I, J);
    int heapsize = 4 + I + J;
    Label address = wordData(getWords(get(v0), heapsize * 4));
    String names[] = {"Bethany", "Alonzo"};
    Label name_buffer = asciiData("Bethany\0", "Alonzo\0");
    Label ans_buffer = wordData(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    run("add_relationship_1", address, name_buffer, 2, ans_buffer);
    for (int i=0; i<6; i+=2) Assert.assertEquals(address.address(), getWord(ans_buffer, i*4));
    for (int i=1; i<7; i+=2) Assert.assertEquals(1, getWord(ans_buffer, i*4));
    for (int i=0; i<names.length; i++) Assert.assertEquals(names[i], getString(getWord(address.address() + 16 + i*4)+4));
    // add friendship between bethany and alonzo
    // Assert.assertEquals(address.address(), getWord(ans_buffer, 4*4));
    int Edge0 = getWord(address.address()+16+I*4);
    int node1 = getWord(Edge0);
    int node2 = getWord(Edge0+4);
    int relationtype = getWord(Edge0+8);
    Assert.assertEquals(2, relationtype);    
    Assert.assertEquals(names[0], getStringFromNode(node1, names[0].length()));
    Assert.assertEquals(names[1], getStringFromNode(node2, names[1].length()));
    // System.out.println();
    // System.out.println(getWord(ans_buffer, 12+I*4));
  }
  @Test
  public void add_relationship_2() {
    // adds the same edge twice (fails)
    int I = 4;
    int J = 6;
    run("create_network", I, J);
    int heapsize = 4 + I + J;
    Label address = wordData(getWords(get(v0), heapsize * 4));
    String names[] = {"Vorax", "Herbert"};
    Label name_buffer = asciiData("Vorax\0", "Herbert\0");
    Label ans_buffer = wordData(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    run("add_relationship_2", address, name_buffer, 2, ans_buffer);
    // for (int k = 0; k < 10; k++)  System.out.println(getWord(ans_buffer, 4*k));  
    for (int i=0; i<6; i+=2) Assert.assertEquals(address.address(), getWord(ans_buffer, i*4));
    for (int i=1; i<7; i+=2) Assert.assertEquals(1, getWord(ans_buffer, i*4));
    for (int i=0; i<names.length; i++) Assert.assertEquals(names[i], getString(getWord(address.address() + 16 + i*4)+4));
    Assert.assertEquals(-1, getWord(ans_buffer, 6*4));
    Assert.assertEquals(-1, getWord(ans_buffer, 7*4));
    // add friendship between bethany and alonzo
    int Edge0 = getWord(address.address()+16+I*4);
    Assert.assertEquals(0, getWord(address.address()+4+16+I*4)); // edge 2 fails
    int node1 = getWord(Edge0);
    int node2 = getWord(Edge0+4);
    int relationtype = getWord(Edge0+8);
    Assert.assertEquals(2, relationtype);    
    Assert.assertEquals(names[0], getStringFromNode(node1, names[0].length()));
    Assert.assertEquals(names[1], getStringFromNode(node2, names[1].length()));
  }
  @Test
  public void add_relationship_3() {
    // fails to create an edge with person not in network
    int I = 4;
    int J = 6;
    run("create_network", I, J);
    int heapsize = 4 + I + J;
    Label address = wordData(getWords(get(v0), heapsize * 4));
    String names[] = {"Bethany", "Alonzo"};
    Label name_buffer = asciiData("Bethany\0", "Alonzo\0", "Jeremy\0");
    Label ans_buffer = wordData(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    run("add_relationship_3", address, name_buffer, 2, ans_buffer);
    for (int i=0; i<4; i+=2) Assert.assertEquals(address.address(), getWord(ans_buffer, i*4));
    for (int i=1; i<5; i+=2) Assert.assertEquals(1, getWord(ans_buffer, i*4));
    for (int i=0; i<names.length; i++) Assert.assertEquals(names[i], getString(getWord(address.address() + 16 + i*4)+4));
    Assert.assertEquals(-1, getWord(ans_buffer, 4*4));
    Assert.assertEquals(-1, getWord(ans_buffer, 5*4));
    // fail add friendship between bethany and Jeremy
    int Edge0 = getWord(address.address()+16+I*4);
    Assert.assertEquals(0, Edge0);    
  }
  @Test
  public void add_relationship_4() {
    // creates an edge
    int I = 4;
    int J = 6;
    run("create_network", I, J);
    int heapsize = 4 + I + J;
    Label address = wordData(getWords(get(v0), heapsize * 4));
    String names[] = {"Bethany"};
    Label name_buffer = asciiData("Bethany\0", "Bethany\0");
    Label ans_buffer = wordData(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    run("add_relationship_1", address, name_buffer, 2, ans_buffer);
    Assert.assertEquals(address.address(), getWord(ans_buffer, 0*4));
    Assert.assertEquals(1, getWord(ans_buffer, 1*4));
    for (int i=0; i<names.length; i++) Assert.assertEquals(names[i], getString(getWord(address.address() + 16 + i*4)+4));
    // fail bc same name
    for (int i=2; i<6; i++) Assert.assertEquals(-1, getWord(ans_buffer, i*4));
    int Edge0 = getWord(address.address()+16+I*4);
    Assert.assertEquals(0, Edge0);
  }
  @Test
  public void get_distant_friends_1() {
    // creates an edge
    int I = 4;
    int J = 6;
    run("create_network", I, J);
    int heapsize = 4 + I + J;
    Label address = wordData(getWords(get(v0), heapsize * 4));
    String Name1 = "Elizabeth";
    String Name2 = "Joey";
    String Name3 = "Demetrius";
    String Name4 = "Constable Jeffrey";
    String Name5 = "Stanislav";
    String Name6 = "Bethany";
    String[] names = {"Elizabeth","Joey","Demetrius","Constable Jeffrey","Stanislav"};
    // Label name_buffer = asciiData("Bethany\0", "Bethany\0");
    Label ans_buffer = wordData(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    run("get_distant_friends_1", address, ans_buffer);
    for (int i=0; i<names.length*2; i++) System.out.print(getWord(ans_buffer, i*4) + " ");
    Assert.assertEquals(address.address(), getWord(ans_buffer, 0*4));
    Assert.assertEquals(1, getWord(ans_buffer, 1*4));
    for (int i=0; i<names.length; i++) Assert.assertEquals(names[i], getString(getWord(address.address() + 16 + i*4)+4));

  }
  @Test
  public void get_distant_friends_2() {
    // creates an edge
    int I = 4;
    int J = 6;
    run("create_network", I, J);
    int heapsize = 4 + I + J;
    Label address = wordData(getWords(get(v0), heapsize * 4));
    String Name1 = "Elizabeth";
    Label name = asciiData(true, Name1);
    // Label name_buffer = asciiData("Bethany\0", "Bethany\0");
    run("get_distant_friends", address, name);
    Assert.assertEquals(-2, get(v0));
  }


  
}