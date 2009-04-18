/*******************************************************************************
 * Copyright (c) 2008 Matthew Hall and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     Matthew Hall - initial API and implementation (bug 215531)
 *     Matthew Hall - bug 228125
 ******************************************************************************/

module org.eclipse.jface.internal.databinding.viewers.ViewerElementMap;
import org.eclipse.jface.internal.databinding.viewers.ViewerElementWrapper;

import java.lang.all;

import java.lang.reflect.Array;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import org.eclipse.core.runtime.Assert;
import org.eclipse.jface.util.Util;
import org.eclipse.jface.viewers.IElementComparer;
import org.eclipse.jface.viewers.StructuredViewer;

/**
 * A {@link Map} whose keys are elements in a {@link StructuredViewer}. The
 * keys in the map are compared using an {@link IElementComparer} instead of
 * {@link #equals(Object)}.
 * <p>
 * This class is <i>not</i> a strict implementation the {@link Map} interface.
 * It intentionally violates the {@link Map} contract, which requires the use of
 * {@link #equals(Object)} when comparing keys. This class is designed for use
 * with {@link StructuredViewer} which uses {@link IElementComparer} for element
 * comparisons.
 * 
 * @since 1.2
 */
public class ViewerElementMap : Map { 

public bool containsKey(String o) {
    return containsKey(stringcast(o));
}
public bool containsValue(String o) {
    return containsValue(stringcast(o));
}
public Object put(Object k, String v) {
    return put((k),stringcast(v));
}
public Object put(String k, Object v) {
    return put(stringcast(k),(v));
}
public Object put(String k, String v) {
    return put(stringcast(k),stringcast(v));
}
public Object get(String k) {
    return get(stringcast(k));
}
public Object remove(String k) {
    return remove(stringcast(k));
}
public int opApply (int delegate(ref Object value) dg){
    foreach( entry; entrySet() ){
        auto me = cast(Map.Entry)entry;
        auto v = me.getValue();
        int res = dg( v );
        if( res ) return res;
    }
    return 0;
}
public int opApply (int delegate(ref Object key, ref Object value) dg){
    foreach( entry; entrySet() ){
        auto me = cast(Map.Entry)entry;
        auto k = me.getKey();
        auto v = me.getValue();
        int res = dg( k, v );
        if( res ) return res;
    }
    return 0;
}

    private Map wrappedMap;
    private IElementComparer comparer;

    /**
     * Constructs a ViewerElementMap using the given {@link IElementComparer}.
     * 
     * @param comparer
     *            the {@link IElementComparer} used for comparing keys.
     */
    public this(IElementComparer comparer) {
        Assert.isNotNull(cast(Object)comparer);
        this.wrappedMap = new HashMap();
        this.comparer = comparer;
    }

    /**
     * Constructs a ViewerElementMap containing all the entries in the specified
     * map.
     * 
     * @param map
     *            the map whose entries are to be added to this map.
     * @param comparer
     *            the {@link IElementComparer} used for comparing keys.
     */
    public this(Map map, IElementComparer comparer) {
        this(comparer);
        Assert.isNotNull(cast(Object)map);
        putAll(map);
    }

    public void clear() {
        wrappedMap.clear();
    }

    public bool containsKey(Object key) {
        return wrappedMap.containsKey(new ViewerElementWrapper(key, comparer));
    }

    public bool containsValue(Object value) {
        return wrappedMap.containsValue(value);
    }

    public Set entrySet() {
        final Set wrappedEntrySet = wrappedMap.entrySet();
        return new class() Set {
public bool add(String o) {
    return add(stringcast(o));
}
public bool remove(String o) {
    return remove(stringcast(o));
}
public bool contains(String o) {
    return contains(stringcast(o));
}
public int opApply (int delegate(ref Object value) dg){
    auto it = iterator();
    while(it.hasNext()){
        auto v = it.next();
        int res = dg( v );
        if( res ) return res;
    }
    return 0;
}
public String toString(){
    return super.toString();
}
            public bool add(Object o) {
                throw new UnsupportedOperationException();
            }

            public bool addAll(Collection c) {
                throw new UnsupportedOperationException();
            }

            public void clear() {
                wrappedEntrySet.clear();
            }

            public bool contains(Object o) {
                for (Iterator iterator = iterator(); iterator.hasNext();)
                    if (iterator.next().opEquals(o))
                        return true;
                return false;
            }

            public bool containsAll(Collection c) {
                for (Iterator iterator = c.iterator(); iterator.hasNext();)
                    if (!contains(iterator.next()))
                        return false;
                return true;
            }

            public bool isEmpty() {
                return wrappedEntrySet.isEmpty();
            }

            public Iterator iterator() {
                final Iterator wrappedIterator = wrappedEntrySet.iterator();
                return new class() Iterator {
                    public bool hasNext() {
                        return wrappedIterator.hasNext();
                    }

                    public Object next() {
                        Map.Entry wrappedEntry = cast(Map.Entry) wrappedIterator
                                .next();
                        return new class() Map.Entry {
                            public Object getKey() {
                                return (cast(ViewerElementWrapper) wrappedEntry.getKey())
                                        .unwrap();
                            }

                            public Object getValue() {
                                return wrappedEntry.getValue();
                            }

                            public Object setValue(Object value) {
                                return wrappedEntry.setValue(value);
                            }

                            public override equals_t opEquals(Object obj) {
                                if (obj is this)
                                    return true;
                                if (obj is null || !(null !is cast(Map.Entry)obj))
                                    return false;
                                Map.Entry that = cast(Map.Entry) obj;
                                return comparer.opEquals(this.getKey(), that
                                        .getKey())
                                        && Util.opEquals(this.getValue(), that
                                                .getValue());
                            }

                            public override hash_t toHash() {
                                return wrappedEntry.toHash();
                            }
                        };
                    }

                    public void remove() {
                        wrappedIterator.remove();
                    }
                };
            }

            public bool remove(Object o) {
                Map.Entry unwrappedEntry = cast(Map.Entry) o;
                final ViewerElementWrapper wrappedKey = new ViewerElementWrapper(
                        unwrappedEntry.getKey(), comparer);
                Map.Entry wrappedEntry = new class() Map.Entry {
                    public Object getKey() {
                        return wrappedKey;
                    }

                    public Object getValue() {
                        return unwrappedEntry.getValue();
                    }

                    public Object setValue(Object value) {
                        throw new UnsupportedOperationException();
                    }

                    public override equals_t opEquals(Object obj) {
                        if (obj is this)
                            return true;
                        if (obj is null || !(null !is cast(Map.Entry)obj))
                            return false;
                        Map.Entry that = cast(Map.Entry) obj;
                        return Util.opEquals(wrappedKey, that.getKey())
                                && Util
                                        .opEquals(this.getValue(), that
                                                .getValue());
                    }

                    public override hash_t toHash() {
                        return wrappedKey.toHash()
                                ^ (getValue() is null ? 0 : getValue()
                                        .toHash());
                    }
                };
                return wrappedEntrySet.remove(cast(Object)wrappedEntry);
            }

            public bool removeAll(Collection c) {
                bool changed = false;
                for (Iterator iterator = c.iterator(); iterator.hasNext();)
                    changed |= remove(iterator.next());
                return changed;
            }

            public bool retainAll(Collection c) {
                bool changed = false;
                Object[] toRetain = c.toArray();
                outer: for (Iterator iterator = iterator(); iterator.hasNext();) {
                    Object entry = iterator.next();
                    for (int i = 0; i < toRetain.length; i++)
                        if (entry.opEquals(toRetain[i]))
                            continue outer;
                    iterator.remove();
                    changed = true;
                }
                return changed;
            }

            public int size() {
                return wrappedEntrySet.size();
            }

            public Object[] toArray() {
                return toArray(new Object[size()]);
            }

            public Object[] toArray(Object[] a) {
                int size = size();
                if (a.length < size) {
                    a = new Object[size];
                }
                int i = 0;
                for (Iterator iterator = iterator(); iterator.hasNext();) {
                    a[i] = iterator.next();
                    i++;
                }
                return a;
            }

            public override equals_t opEquals(Object obj) {
                if (obj is this)
                    return true;
                if (obj is null || !(null !is cast(Set)obj))
                    return false;
                Set that = cast(Set) obj;
                return this.size() is that.size() && containsAll(that);
            }

            public override hash_t toHash() {
                return wrappedEntrySet.toHash();
            }
        };
    }

    public Object get(Object key) {
        return wrappedMap.get(new ViewerElementWrapper(key, comparer));
    }

    public bool isEmpty() {
        return wrappedMap.isEmpty();
    }

    public Set keySet() {
        final Set wrappedKeySet = wrappedMap.keySet();
        return new class() Set {
public bool add(String o) {
    return add(stringcast(o));
}
public bool remove(String o) {
    return remove(stringcast(o));
}
public bool contains(String o) {
    return contains(stringcast(o));
}
public int opApply (int delegate(ref Object value) dg){
    auto it = iterator();
    while(it.hasNext()){
        auto v = it.next();
        int res = dg( v );
        if( res ) return res;
    }
    return 0;
}
public String toString(){
    return super.toString();
}
            public bool add(Object o) {
                throw new UnsupportedOperationException();
            }

            public bool addAll(Collection c) {
                throw new UnsupportedOperationException();
            }

            public void clear() {
                wrappedKeySet.clear();
            }

            public bool contains(Object o) {
                return wrappedKeySet.contains(new ViewerElementWrapper(o, comparer));
            }

            public bool containsAll(Collection c) {
                for (Iterator iterator = c.iterator(); iterator.hasNext();)
                    if (!wrappedKeySet.contains(new ViewerElementWrapper(iterator.next(), comparer)))
                        return false;
                return true;
            }

            public bool isEmpty() {
                return wrappedKeySet.isEmpty();
            }

            public Iterator iterator() {
                final Iterator wrappedIterator = wrappedKeySet.iterator();
                return new class() Iterator {
                    public bool hasNext() {
                        return wrappedIterator.hasNext();
                    }

                    public Object next() {
                        return (cast(ViewerElementWrapper) wrappedIterator.next()).unwrap();
                    }

                    public void remove() {
                        wrappedIterator.remove();
                    }
                };
            }

            public bool remove(Object o) {
                return wrappedKeySet.remove(new ViewerElementWrapper(o, comparer));
            }

            public bool removeAll(Collection c) {
                bool changed = false;
                for (Iterator iterator = c.iterator(); iterator.hasNext();)
                    changed |= wrappedKeySet
                            .remove(new ViewerElementWrapper(iterator.next(), comparer));
                return changed;
            }

            public bool retainAll(Collection c) {
                bool changed = false;
                Object[] toRetain = c.toArray();
                outer: for (Iterator iterator = iterator(); iterator.hasNext();) {
                    Object element = iterator.next();
                    for (int i = 0; i < toRetain.length; i++)
                        if (comparer.opEquals(element, toRetain[i]))
                            continue outer;
                    // element not contained in collection, remove.
                    remove(element);
                    changed = true;
                }
                return changed;
            }

            public int size() {
                return wrappedKeySet.size();
            }

            public Object[] toArray() {
                return toArray(new Object[wrappedKeySet.size()]);
            }

            public Object[] toArray(Object[] a) {
                int size = wrappedKeySet.size();
                ViewerElementWrapper[] wrappedArray = cast(ViewerElementWrapper[]) wrappedKeySet
                        .toArray(new ViewerElementWrapper[size]);
                Object[] result = a;
                if (a.length < size) {
                    result = new Object[size];
                }
                for (int i = 0; i < size; i++)
                    result[i] = wrappedArray[i].unwrap();
                return result;
            }

            public override equals_t opEquals(Object obj) {
                if (obj is this)
                    return true;
                if (obj is null || !(null !is cast(Set)obj))
                    return false;
                Set that = cast(Set) obj;
                return this.size() is that.size() && containsAll(that);
            }

            public override hash_t toHash() {
                return wrappedKeySet.toHash();
            }
        };
    }

    public Object put(Object key, Object value) {
        return wrappedMap.put(new ViewerElementWrapper(key, comparer), value);
    }

    public void putAll(Map other) {
        for (Iterator iterator = other.entrySet().iterator(); iterator
                .hasNext();) {
            Map.Entry entry = cast(Map.Entry) iterator.next();
            wrappedMap.put(new ViewerElementWrapper(entry.getKey(), comparer), entry.getValue());
        }
    }

    public Object remove(Object key) {
        return wrappedMap.remove(new ViewerElementWrapper(key, comparer));
    }

    public int size() {
        return wrappedMap.size();
    }

    public Collection values() {
        return wrappedMap.values();
    }

    public override equals_t opEquals(Object obj) {
        if (obj is this)
            return true;
        if (obj is null || !(null !is cast(Map)obj))
            return false;
        Map that = cast(Map) obj;
        return (cast(Object)this.entrySet()).opEquals(cast(Object)that.entrySet());
    }

    public override hash_t toHash() {
        return wrappedMap.toHash();
    }

    /**
     * Returns a Map for mapping viewer elements as keys to values, using the
     * given {@link IElementComparer} for key comparisons.
     * 
     * @param comparer
     *            the element comparer to use in key comparisons. If null, the
     *            returned map will compare keys according to the standard
     *            contract for {@link Map} interface contract.
     * @return a Map for mapping viewer elements as keys to values, using the
     *         given {@link IElementComparer} for key comparisons.
     */
    public static Map withComparer(IElementComparer comparer) {
        if (comparer is null)
            return new HashMap();
        return new ViewerElementMap(comparer);
    }
}
